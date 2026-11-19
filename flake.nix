{
  description = "gmpublisher, a Workshop publishing utility for Garry's Mod";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" ];

      forAllSystems =
        f:
        lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
              config.allowUnfreePredicate = pkg: lib.getName pkg == "gmpublisher";
            }
          )
        );
    in
    {
      overlays.default = final: _prev: {
        gmpublisher = final.callPackage ./pkgs/by-name/gm/gmpublisher/package.nix { };
      };

      packages = forAllSystems (pkgs: {
        inherit (pkgs) gmpublisher;
        default = pkgs.gmpublisher;
      });

      checks = forAllSystems (pkgs: {
        inherit (pkgs) gmpublisher;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
