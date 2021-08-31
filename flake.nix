{
  description = "template for developing/testing nixos modules";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-shell.url = "github:mic92/nixos-shell";
  };

  outputs = { self, nixpkgs, nixos-shell }:
    let

      lib = nixpkgs.lib;

      supportedSystems = [
        "x86_64-linux"
      ];

      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = lib.genAttrs supportedSystems (system: nixpkgs.legacyPackages."${system}");

    in
    {

      nixosModules.example-module = import ./module.nix;

      devShell = forAllSystems (system:
        nixpkgsFor."${system}".mkShell {
          buildInputs = [
            nixos-shell.defaultPackage."${system}"
          ];
        }
      );

      packages = forAllSystems (system: {
        nixos-vm =
          let
            nixos = lib.nixosSystem {
              inherit system;
              modules = [
                self.nixosModules.example-module
              ];
            };
          in
            nixos.config.system.build.vm;
      });

      apps = forAllSystems (system: {

        vm = {
          type = "app";
          program = builtins.toString (nixpkgs.legacyPackages."${system}".writeScript "vm" ''
            ${self.packages."${system}".nixos-vm}/bin/run-nixos-vm
          '');
        };

        vm-clear-state = {
          type = "app";
          program = builtins.toString (nixpkgs.legacyPackages."${system}".writeScript "vm-clear-state" ''
            rm nixos.qcow2
          '');
        };

        nixos-shell = {
          type = "app";
          program = builtins.toString (nixpkgs.legacyPackages."${system}".writeScript "nixos-shell" ''
            ${nixos-shell.defaultPackage."${system}"}/bin/nixos-shell \
              -I nixpkgs=${nixpkgs} \
              ./module.nix
          '');
        };

      });

    };
}
