## Examples on how to test nixos-modules (defined in flakes)
This repo contains a flake.nix which exposes an example nixos module and demonstrates different ways how a module can be tested.

Feel free to contribute your ideas about nixos module related workflows.

The example module is located under `./module.nix`. It enables nginx and sets the root password to `root`.

In all subsequent examles, this module is used to build a nixos machine.

All exampls are implemented via flake apps found in `./flake.nix`

Feel free to copy those apps into other flakes to simplify testing for developers of that flake.


### Method 1: run as qemu vm:
```
nix run .#vm
```

### Method 2: run as qemu vm using [mic92/nixos-shell](https://github.com/Mic92/nixos-shell):
nixos-shell does some extra magic to increase comfort (keeping your $HOME and shell etc.)  
for more options/examples see [mic92/nixos-shell](https://github.com/Mic92/nixos-shell)
```
nix run .#nixos-shell
```

### Alternative: Include module from remote flake into non-flake based config/module:
example non-flake based configuration.nix:
```
{ pkgs, ... }: {
  imports = [
    (builtins.getFlake "github:user/project?rev={rev}").nixosModules.example-module
  ];
  # use example-module options here
  # ...
}
```


### Other known methods of testing modules (not described in this repo):
- nixos-container (requires nixos; see [Imparative Container Management](https://nixos.org/manual/nixos/stable/#sec-imperative-containers) section in nixos manual)
- [extra-container](https://github.com/erikarvstedt/extra-container) (requires nixos; based on nixos-container)
- nixops:
  - use virtualbox plugin to provision local vm
  - deploy on exisitng vm (local or cloud)
- use module with your existing nixos machine
