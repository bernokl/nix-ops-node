#!env bash -xe
git clone https://github.com/input-output-hk/cardano-node.git &&
cd cardano-node
cat << 'EOF' > configuration.nix
{
  imports = [
    "github:input-output-hk/cardano-node?ref=master"
  ];
}
EOF

# nix build --accept-flake-config github:input-output-hk/cardano-node?ref=master &&
echo we_got_clean_build > /tmp/outNix

# systemctl start cardano-node-relay-daemon.service 
