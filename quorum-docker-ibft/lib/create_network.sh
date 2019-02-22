#!/bin/bash

source qm.variables
source lib/common.sh

#function to generate keyPair for node
function generateKeyPair(){
    echo -ne "\n" | constellation-node --generatekeys=${mNode} 1>>/dev/null

    echo -ne "\n" | constellation-node --generatekeys=${mNode}a 1>>/dev/null

    mv ${mNode}*.*  ${mNode}/node/keys/.

}

#function to create node initialization script
function createInitNodeScript(){
    cp lib/master/init_template.sh ${mNode}/init.sh
    chmod +x ${mNode}/init.sh
}

#function to create start node script with --raft flag
function copyScripts(){
    NET_ID=38977
    
    cp lib/master/start_quorum_template.sh ${mNode}/node/start_${mNode}.sh
    chmod +x ${mNode}/node/start_${mNode}.sh

    cp lib/master/start_template.sh ${mNode}/start.sh
    chmod +x ${mNode}/start.sh

    cp lib/master/pre_start_check_template.sh ${mNode}/node/pre_start_check.sh
    START_CMD="start_${mNode}.sh"
    PATTERN="s/#start_cmd#/${START_CMD}/g"
    sed -i $PATTERN ${mNode}/node/pre_start_check.sh
    PATTERN="s/#nodename#/${mNode}/g"
    sed -i $PATTERN ${mNode}/node/pre_start_check.sh
    PATTERN="s/#netid#/${NET_ID}/g"
    sed -i $PATTERN ${mNode}/node/pre_start_check.sh
    chmod +x ${mNode}/node/pre_start_check.sh

    cp lib/common.sh ${mNode}/node/common.sh

    cp lib/master/constellation_template.conf ${mNode}/node/${mNode}.conf

    cp lib/master/tessera-migration.properties ${mNode}/node/qdata

    cp lib/master/empty_h2.mv.db ${mNode}/node/qdata/${mNode}.mv.db

    cp lib/master/migrate_to_tessera.sh ${mNode}/node
    PATTERN="s/#mNode#/${mNode}/g"
    sed -i $PATTERN ${mNode}/node/migrate_to_tessera.sh

}

#function to generate enode
function generateEnode(){
    cp nodekey1 ${mNode}/node/qdata/geth/nodekey
    cp lib/master/static-nodes.json ${mNode}/node/qdata/static-nodes.json
}

#function to create node accout and append it into genesis.json file
function createAccount(){
    cat lib/master/genesis.json >> ${mNode}/node/genesis.json
}

function cleanup(){
    rm -rf ${mNode}
    echo $mNode > .nodename
    mkdir -p ${mNode}/node/keys
    mkdir -p ${mNode}/node/contracts
    mkdir -p ${mNode}/node/qdata
    mkdir -p ${mNode}/node/qdata/{keystore,geth,logs}
    cp qm.variables $mNode
}

# execute init script
function executeInit(){
    cd ${mNode}
    ./init.sh
}


function readParameters() {
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -n|--name)
            mNode="$2"
            shift # past argument
            shift # past value                        
            ;;            
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    if [ -z "$mNode" ]; then
        return
    fi

    if [ -z "$mNode" ]; then
        help
    fi

    NON_INTERACTIVE=true
}

function main(){    

    readParameters $@

    if [ -z "$NON_INTERACTIVE" ]; then
        getInputWithDefault '请输入节点名称' "" mNode $GREEN
    fi
        
    cleanup
    generateKeyPair
    createInitNodeScript
    copyScripts
    generateEnode
    createAccount
    executeInit   
}

main $@
