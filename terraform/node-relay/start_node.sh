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
yes | nix build github:input-output-hk/cardano-node?ref=master &&
echo node_done_buiding > /tmp/outNix
yes | nix run github:input-output-hk/cardano-node?ref=master run
