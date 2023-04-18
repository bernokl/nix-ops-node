{
  inputs.std.url = "github:divnix/std";
  inputs.nixpkgs.url = "nixpkgs";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nix-cache.url = "github:edolstra/nix-serve"; 

  outputs = { std, ... } @ inputs:
    std.growOn
      {
        inherit inputs;
        cellsFrom = ./nix;
        cellBlocks = [
          (std.blockTypes.runnables "apps")
          (std.blockTypes.runnables "entrypoints")

          # The `devshell` type will allow us to have "development shells"
          # available. These are managed by `numtide/devshell`.
          # See: https://github.com/numtide/devshell
          (std.blockTypes.devshells "devshells")

          # The `function` type is a generic block type that allows us to define
          # some common Nix code that can be used in other cells. In this case,
          # we're defining a toolchain cell block that will contain derivations
          # for the Rust toolchain.
          (std.blockTypes.functions "toolchain")
        ];
      }
      {
#        packages = std.harvest inputs.self [ "cache-server" "entrypoints" ];
        packages = std.harvest inputs.self [ "rust-app" "apps" ];
#        packages = std.harvest inputs.self [ [ "cache-server" "entrypoints" ] [ "rust-app" "apps" ] ];

        # We want to export our development shells so that the following works
        # as expected:
        #
        # > nix develop
        #
        # Or, we can put the following in a .envrc:
        #
        # use flake
          devShells = std.harvest inputs.self [ "devshells" ];
      };
}

