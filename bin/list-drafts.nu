#!/usr/bin/env nu

def main [] {
    rg -l 'draft:\s*true' ./content/blog/
}
