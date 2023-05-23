#!/usr/bin/env bash
set -xe
git clone https://github.com/input-output-hk/cardano-node.git &&

# Populate config files
# This is for the preprod testnet
/run/current-system/sw/bin/curl -o /cardano-node/configuration/cardano/testnet-topology.json https://book.world.dev.cardano.org/environments/preprod/topology.json 
/run/current-system/sw/bin/curl -o /cardano-node/configuration/cardano/testnet-byron-genesis.json https://book.world.dev.cardano.org/environments/preprod/byron-genesis.json 
/run/current-system/sw/bin/curl -o /cardano-node/configuration/cardano/testnet-shelley-genesis.json https://book.world.dev.cardano.org/environments/preprod/shelley-genesis.json 
/run/current-system/sw/bin/curl -o /cardano-node/configuration/cardano/testnet-alonzo-genesis.json https://book.world.dev.cardano.org/environments/preprod/alonzo-genesis.json 
/run/current-system/sw/bin/curl -o /cardano-node/configuration/cardano/testnet-conway-genesis.json https://book.world.dev.cardano.org/environments/preprod/conway-genesis.json  
/run/current-system/sw/bin/curl -o /cardano-node/configuration/cardano/testnet-config.json https://book.world.dev.cardano.org/environments/preprod/config.json  
# Fix paths set in official config.json
sed -i 's/conway-genesis.json/testnet-conway-genesis.json/g' /cardano-node/configuration/cardano/testnet-config.json
sed -i 's/alonzo-genesis.json/testnet-alonzo-genesis.json/g' /cardano-node/configuration/cardano/testnet-config.json
sed -i 's/byron-genesis.json/testnet-byron-genesis.json/g' /cardano-node/configuration/cardano/testnet-config.json
sed -i 's/shelley-genesis.json/testnet-shelley-genesis.json/g' /cardano-node/configuration/cardano/testnet-config.json

cd /cardano-node
cat << 'EOF' > configuration.nix
{
  imports = [
    "github:input-output-hk/cardano-node?ref=master"
  ];
}
EOF



nix build --accept-flake-config github:input-output-hk/cardano-node?ref=master  &> /tmp/cardano-node-build.log

echo we_got_clean_build > /tmp/outNix

touch /tmp/cardano-node.socket

systemctl start cardano-node-relay-daemon.service 
