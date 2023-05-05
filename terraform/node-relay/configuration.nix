{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  ec2.hvm = true;

  nix.extraOptions = ''
    extra-experimental-features = nix-command
    extra-experimental-features = flakes
    extra-substituters = 1
  '';

  systemd.services.cardano-node-relay-daemon = {
    enable = true;
    description = "Cardano relay daemon";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.nix}/bin/nix run --accept-flake-config github:input-output-hk/cardano-node?ref=master run";
      Restart = "always";
      User = "root";
      WorkingDirectory="/cardano-node/";
      RestartSec = 1;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    lsof
  ];
}

