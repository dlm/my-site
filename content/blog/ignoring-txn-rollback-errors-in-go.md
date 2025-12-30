---
title: "Ignoring Transaction Rollback Errors in Golang"
date: 2025-12-15
---

(originally published 2023-04-01 on Medium)

A few days ago I was working on a pull request that interacted with a
relational database in go. In the go
[documentation](https://go.dev/doc/database/execute-transactions) (and almost
any tutorial about relational databases and go), it is common to see the
following pattern:

```go
func doSomeDBThing(db *sql.DB) error{
    // create the db transaction
    tx, err := db.Begin()
    // handle error

    // Defer a rollback in case anything fails.
    defer tx.Rollback()

    // ... do things with the transacton

    // Commit the transaction.
    err = tx.Commit()
    // handle error

    return nil
}
```

But, since the `Rollback()` function is error-able, code linters will tell you
that you are not handling the error in the defer statement. So one way to
address is to update the defer statement to "mute" the error.

```go
defer func() { _ = tx.Rollback() }()
```

But why is this okay? If rollback fails, isn't that a problem? Let's explore.

## Errors from Rollback

Consider the two cases in which we are performing the rollback:

1. the happy path (e.g. commit was successful). The rollback will fail because
   it is trying to rollback a transaction that is committed. So, the failure of
   the rollback invoked by the defer is expected. (So maybe one should actually
   produce an error if the rollback did not error?)
2. the not happy path (e.g. something failed before and including the commit).
   The function failed so we should return an error. Now the question is which
   one? It seems that in most instances, developers return the source of the error
   and do not add the additional context from the rollback failure, if one
   occurred. An so ignoring the error becomes the standard practice.

Perhaps it goes without saying, but if you did want to capture the rollback
error, you always can. For example, via error wrapping:

```go
func doSomeDBThing(db *sql.DB) (retErr error) {
    ...
	defer func() {
		if rollbackErr := tx.Rollback(); rollbackErr != nil {
			retErr = errors.Join(
				retErr,
				fmt.Errorf("rolling back transaction: %w", rollbackErr),
			)
		}
	}()
    ...
}
```

Note though that since we expect the rollback to fail in the happy path, we
only want to add the context of the error if we are already returning an error.

## A few other notes

As I was thinking about this issue, I started to wonder about correctness. That
is, what is the database state if the rollback fails? The good news is that go
database [documentation](https://go.dev/doc/database/execute-transactions) tell
us that

> Even if Tx.Rollback fails, the transaction will no longer be valid, nor will
> it have been committed to the database.

So great! Our system should still be working properly!
