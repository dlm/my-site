---
title: "Using Wavebox on NixOS"
date: 2026-06-01
---

I've been using [Wavebox](https://wavebox.io/) for a while now, and it's
become one of my most-used tools. Despite being built on Chromium, I don't
really use it as a browser in the traditional sense. Instead, I use it as a
collection of site-specific browsers (SSBs) — each app or service I use lives
in its own isolated container with its own cookies, sessions, and identity.
It's a fantastic way to keep work, personal, and side-project contexts cleanly
separated.

The only problem though is that Wavebox isn't in nixpkgs. It was for a while
but was abandoned.

## Wrapping an AppImage for Nix

Wavebox distributes a Linux build as an AppImage, which is self-contained but
doesn't integrate with NixOS out of the box. To integrate, I wrote a small
Nix flake that fetches the AppImage and wraps it using `appimage-run`.

You can find the full package on [my
github](https://github.com/dlm/nixos/blob/78ddc020ab8f194a68175d0c698702d57235bd1b/packages/wavebox/flake.nix).
Here's the code:

```nix
{
  description = "Wavebox browser package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation rec {
        pname = "wavebox";
        version = "148.2.44-2";

        src = pkgs.fetchurl {
          url = "https://download.wavebox.app/stable/linux/appimage/Wavebox_${version}_x86_64.AppImage";
          hash = "sha256-LIM9NFx2wtOUfeC9s0sfycYHfcBn4VW5dLIOSx8m5hc=";
        };

        nativeBuildInputs = [ pkgs.appimage-run ];

        dontUnpack = true;
        dontStrip = true;
        dontPatchELF = true;

        installPhase = ''
          install -D $src $out/bin/wavebox.AppImage

          cat > $out/bin/wavebox << WRAPPER
          #!${pkgs.runtimeShell}
          exec ${pkgs.appimage-run}/bin/appimage-run $out/bin/wavebox.AppImage "$@"
          WRAPPER
          chmod +x $out/bin/wavebox

          install -Dm644 ${./wavebox.png} $out/share/pixmaps/wavebox.png

          mkdir -p $out/share/applications
          cat > $out/share/applications/wavebox.desktop << DESKTOP
          [Desktop Entry]
          Name=Wavebox
          Exec=$out/bin/wavebox
          Icon=$out/share/pixmaps/wavebox.png
          Type=Application
          Categories=Network;WebBrowser;
          DESKTOP
        '';

        meta = with pkgs.lib; {
          description = "Wavebox browser (AppImage) wrapped for Nix/NixOS";
          homepage = "https://wavebox.io/";
          license = licenses.unfree;
          platforms = platforms.linux;
        };
      };
    };
}
```

A few things worth noting:

- `dontUnpack`, `dontStrip`, and `dontPatchELF` are all set because we're not
  building from source — the AppImage is opaque and should be left alone.
- AppImages tend to hard code paths to system libraries and so they often do not
  work on NixOS out of the box. The `appimage-run` package fixes that.
- The wrapper script at `$out/bin/wavebox` is what actually gets run. It simply calls
  `appimage-run` with the bundled `.AppImage` and addition user provided arguments.
- A `.desktop` file and icon are installed so Wavebox shows up in your
  application launcher.  The icon is part of the package that I built.
  Technically, you can fish it out of the app image, which is what I did in the
  first version, but it is very ugly and likely brittle.

## Using the Package

I pull the wavebox flake into my main [NixOS
config](https://github.com/dlm/nixos/blob/78ddc020ab8f194a68175d0c698702d57235bd1b/flake.nix#L16-L19)
as a local path input:

```nix
wavebox = {
  url = "path:./packages/wavebox";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then reference `inputs.wavebox.packages.${system}.default` wherever I install
packages. For example, in my multi-system configuration, I have it in my
[common host
configuration](https://github.com/dlm/nixos/blob/78ddc020ab8f194a68175d0c698702d57235bd1b/hosts/common/configuration.nix).
But, if you don't want to wire it into a full config, you could also just run
it directly:

```bash
nix run github:dlm/nixos?dir=packages/wavebox --no-write-lock-file
```

The `--no-write-lock-file` flag is needed because Nix tries to write a lockfile
back to the remote flake, which is read-only.

## Updating to a New Version

I was very happy with how easy updates were. When
Wavebox releases a new version, I just changed two lines:

1. **`version`** — update the version string
2. **`hash`** — update the sha256 hash for the new AppImage

To get the new hash, get the app image file and convert the output to the
`sha256-<base64>` format that modern Nix expects. In `nu` shell, we can use the
one-liner:

```nu
nix-prefetch-url https://download.wavebox.app/stable/linux/appimage/Wavebox_<new-version>_x86_64.AppImage
  | nix hash to-sri --type sha256 $in
```

Or, if you just put in a placeholder hash and run the build, Nix will error out
and tell you the correct hash — a quick shortcut.

That's it. Two lines changed, and Wavebox is updated. No patching, no build
system, no upstream packaging required.  With nix, when the pieces fit, it is
just magical!
