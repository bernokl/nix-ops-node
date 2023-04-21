{
  inputs,
  cell,
}: let

   inherit (inputs) nixpkgs std;
   l = nixpkgs.lib // builtins;
   inherit (inputs.std.lib) ops;


in {

    myhost = ops.mkMicrovm ({ pkgs, lib, ... }: { networking.hostName = "microvms-host";});

}
