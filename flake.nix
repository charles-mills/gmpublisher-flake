{
  description = "Nix flake for gmpublisher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-webkit.url = "github:NixOS/nixpkgs/50ab793786d9de88ee30ec4e4c24fb4236fc2674";
  };

  outputs =
    { nixpkgs, nixpkgs-webkit, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          isDarwin = nixpkgs.lib.hasSuffix "darwin" system;
          pkgs = (if isDarwin then nixpkgs else nixpkgs-webkit).legacyPackages.${system};
          package = pkgs.callPackage (
            if isDarwin then ./pkgs/gmpublisher-darwin.nix else ./pkgs/gmpublisher-linux.nix
          ) { };
        in
        {
          default = package;
          gmpublisher = package;
        }
      );
    };
}
