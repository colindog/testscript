#!/bin/bash
set -u
set -e

mkdir -p qdata/logs

echo "[*] Starting Ethereum nodes"
set -v
ARGS="--nodiscover --syncmode full --mine --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul"
nohup geth --datadir qdata/dd1 $ARGS --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/1.log &
nohup geth --datadir qdata/dd2 $ARGS --rpcport 22001 --port 21001 2>>qdata/logs/2.log &
nohup geth --datadir qdata/dd3 $ARGS --rpcport 22002 --port 21002 2>>qdata/logs/3.log &
nohup geth --datadir qdata/dd4 $ARGS --rpcport 22003 --port 21003 2>>qdata/logs/4.log &
set +v

echo
echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node."
echo "To test sending a private transaction from Node 1 to Node 7, run './runscript.sh private-contract.js'"
