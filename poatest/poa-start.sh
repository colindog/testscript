#!/bin/bash
set -u
set -e

mkdir -p qdata/logs

echo "[*] Starting Ethereum nodes"

pm2 start poa-run.json

echo
echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node."
echo "To test sending a private transaction from Node 1 to Node 7, run './runscript.sh private-contract.js'"
