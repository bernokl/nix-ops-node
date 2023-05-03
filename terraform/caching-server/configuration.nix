{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;

  nix.extraOptions = ''
      extra-experimental-features = nix-command
      extra-experimental-features = flakes
    '';

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    lsof
  ];

}

