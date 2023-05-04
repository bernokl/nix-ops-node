{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;

  nix.extraOptions = ''
      extra-experimental-features = nix-command
      extra-experimental-features = flakes
      extra-substituters = 1
    '';

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    lsof
  ];

}

