{ config, lib, pkgs, modulesPath, ... }:
let
   system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
   nixos-unstable = import <nixos-unstable> {};

in {
#{
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

 services.tailscale.enable = true;

 systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
#      ${tailscale}/bin/tailscale up --ssh -authkey tskey-auth-kmcS2Y1CNTRL-QnXeJhyWdmNebfaVyEskuNt9MNn2ZMjCP
      ${tailscale}/bin/tailscale up --ssh -authkey tskey-auth-xxxxxxxxxxxxxxx
    '';
};

  networking.firewall = {
    checkReversePath = "loose";
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tailscale
    lsof
  ];
}

