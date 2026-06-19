A Nix flake for [gmpublisher](https://github.com/WilliamVenner/gmpublisher), supporting MacOS and Linux.

## Usage

Run without installing:

```sh
nix run github:charles-mills/gmpublisher-flake
```

Install from another flake:

```nix
{
  inputs.gmpublisher-flake.url = "github:charles-mills/gmpublisher-flake";
}
```

Then use the package in a NixOS or Home Manager module:

```nix
{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.gmpublisher-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```
