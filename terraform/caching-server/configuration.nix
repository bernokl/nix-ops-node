{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;


  environment.systemPackages = with pkgs; [
    git
    vim
  ];

}

