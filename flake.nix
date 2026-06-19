{
  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-unstable = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      ...
    }:
    inputs.flake-parts.lib.mkFlake
      {
        inherit
          inputs
          ;
      }
      {
        systems = [
          "x86_64-linux"
          "x86_64-darwin"
        ];

        flake =
          {
            ...
          }:
          {
            nixosModules = {
              default = self.nixosModules.binternet;
              binternet = import ./nix/module.nix {
                inherit
                  self
                  ;
              };
            };
          };

        perSystem =
          {
            self',
            pkgs,
            ...
          }:
          {
            packages = {
              default = self'.packages.binternet;
              binternet = pkgs.callPackage ./nix/package.nix { };
            };
          };

        debug = true;
      };
}
