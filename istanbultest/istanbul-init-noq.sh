#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node 1"
mkdir -p qdata/dd1/{keystore,geth}
cp permissioned-nodes.json qdata/dd1/static-nodes.json
cp keystore/UTC--2018-07-23T05-40-17.457264700Z--f8ae1810e4e76843717fc487ef2a2934ce9e6699 qdata/dd1/keystore
cp nodekey/nodekey1 qdata/dd1/geth/nodekey
geth --datadir qdata/dd1 init istanbul-genesis-noq.json

echo "[*] Configuring node 2"
mkdir -p qdata/dd2/{keystore,geth}
cp permissioned-nodes.json qdata/dd2/static-nodes.json
cp keystore/UTC--2018-07-23T05-40-58.257785500Z--f9bd6f7a66fce17361409a16229201bcb281ad31 qdata/dd2/keystore
cp nodekey/nodekey2 qdata/dd2/geth/nodekey
geth --datadir qdata/dd2 init istanbul-genesis-noq.json

echo "[*] Configuring node 3"
mkdir -p qdata/dd3/{keystore,geth}
cp permissioned-nodes.json qdata/dd3/static-nodes.json
cp keystore/UTC--2018-07-23T05-41-03.970169900Z--6daea63b17689562a03ee5f5a6e96c3693300320 qdata/dd3/keystore
cp nodekey/nodekey3 qdata/dd3/geth/nodekey
geth --datadir qdata/dd3 init istanbul-genesis-noq.json

echo "[*] Configuring node 4 as voter"
mkdir -p qdata/dd4/{keystore,geth}
cp permissioned-nodes.json qdata/dd4/static-nodes.json
cp keystore/UTC--2018-07-23T05-41-08.993347100Z--086fd53659fa1c0a78610046f061efd36144c89b qdata/dd4/keystore
cp nodekey/nodekey4 qdata/dd4/geth/nodekey
geth --datadir qdata/dd4 init istanbul-genesis-noq.json
