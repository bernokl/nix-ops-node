{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std lib;
#  inherit (inputs.nix-cache.packages) nix-serve;
#  l = nixpkgs.lib //builtins;

in {
  default = (lib.dev.mkShell {
    name = "yumi-shell";
    imports = [ std.devshellProfiles.default ];
    packages = [
      cell.rust-app.toolchain.rust.stable.latest.default
      nix-serve
    ];
    commands = [
#      {
#        name = "tests";
#        command = "cargo test";
#        help = "run the unit tests";
#        category = "Testing";
#      }
      {
        name = "serve";
#        command = "${nix-serve}/bin/nix-serve --port 8080";
        command = "echo hi";
        help = "run the the cache-server";
        category = "Testing";
      }

    ];
  }) // { meta.description = "General development shell with default yumi operations environment."; }; 

}



