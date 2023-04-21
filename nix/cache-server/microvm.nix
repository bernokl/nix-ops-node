{
  inputs,
  cell,
}: let
   inherit (inputs) nixpkgs std;
   l = nixpkgs.lib // builtins;

   pkgs = nixpkgs.legacyPackages.${system};

   std_divnix = (import std { inherit nixpkgs system; }).blocktypes.microvms;
   alpine = pkgs.dockerTools.pullImage {
     imageName = "alpine";
     imageDigest = "sha256:28ef97b8686a049f3d2892b3f3b02b48f32b9a51a8a88d50b3c3a2e3f335bffc";
     sha256 = "0jgdil7i0x0z8v7ff1wpf1yz7bgjmhgnwz0k7gjsijfhmx1n94i6";
   };

in {

   alpine-microvm = std_divnix.buildMicroVM {
     name = "alpine-microvm";
     kernel = std_divnix.linuxKernel;
     rootfs = pkgs.dockerTools.imageToRootfs alpine;
     cmdline = "console=ttyS0";
     extraConfig = ''
       boot.kernelParams = ["console=ttyS0"];
     '';
   };


}
