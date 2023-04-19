{
  inputs,
  cell,
}: let
   inherit (inputs) nixpkgs std;
   l = nixpkgs.lib // builtins;

   name = "nix-cache-server";
   operable = cell.entrypoints.nix-cache-server;
in {
   nix-cache-server = std.lib.ops.mkStandardOCI {
     inherit name operable;
   };
   nix-cache-server-debug = std.lib.ops.mkStandardOCI {
     inherit name operable;
     debug = true;
   };

}
