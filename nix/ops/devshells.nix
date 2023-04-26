{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std lib;
  inherit (inputs.nix-cache.packages) nix-serve;
  inherit (inputs.cells.rust-app.toolchain) rust;
  l = nixpkgs.lib //builtins;

in {
  dev = (lib.dev.mkShell {
    name = "yumi-shell";
    imports = [ std.devshellProfiles.default ];
    packages = [
# Note I had to inherit the cell above because it is now running from different folders
# This no longer works in the new nix/ops nix/rust-app folder structure
#      cell.rust-app.toolchain.rust.stable.latest.default
# After I did the import above I could reference the package...
      rust.stable.latest.default
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
#        command = "echo hi";
        help = "run the the cache-server";
        category = "Testing";
      }
      {
        name = "launch_aws";
        command = "ec2-run-instances -t t2.large --region ap-southeast-2 -W $AWS_SECRET_KEY  -O $AWS_ID -b '/dev/xvda=:25' -k gsg-keypair ami-0638db75ba113c635";
        help = "start a new aws instance using ec2-run";
        category = "Infra";
      }

    ];
  }) // { meta.description = "General development shell with default yumi operations environment."; }; 

}



