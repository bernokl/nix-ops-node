{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std lib;
  inherit (inputs.nix-cache.packages) nix-serve;

in {
  dev = (lib.dev.mkShell {

    name = "example-devshell";

    imports = [ std.devshellProfiles.default ];

    packages = [
      cell.toolchain.rust.stable.latest.default
      nix-serve
    ];

    commands = [
      {
        name = "tests";
        command = "cargo test";
        help = "run the unit tests";
        category = "Testing";
      }

      {
        name = "serve";
        command = "${nix-serve}/bin/nix-serve --port 8080";
        help = "run the unit tests";
        category = "Testing";
      }

    ];
  }) // { meta.description = "General development shell with default yumi environment."; }; 

}



