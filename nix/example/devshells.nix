{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std lib;
  l = nixpkgs.lib // builtins;

in {
  dev = (lib.dev.mkShell {

    name = "example devshell";

    imports = [ std.devshellProfiles.default ];

    packages = [
      cell.toolchain.rust.stable.latest.default
    ];

    commands = [
      {
        name = "tests";
        command = "cargo test";
        help = "run the unit tests";
        category = "Testing";
      }
    ];
  }) // { meta.description = "General development shell with default yumi environment."; }; 

}



