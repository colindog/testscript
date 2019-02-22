#!/bin/bash

source qm.variables
source node/common.sh

function readParameters() {
    
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            --ip)
            pCurrentIp="$2"
            shift # past argument
            shift # past value
            ;;
            -r|--rpc)
            rPort="$2"
            shift # past argument
            shift # past value
            ;;
            -w|--whisper)
            wPort="$2"
            shift # past argument
            shift # past value
            ;;
            -c|--constellation)
            cPort="$2"
            shift # past argument
            shift # past value
            ;;
            --ws)
            wsPort="$2"
            shift # past argument
            shift # past value
            ;;
            -t|--tessera)
            tessera="true"
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

    if [[ -z "$pCurrentIp" && -z "$rPort" && -z "$wPort" && -z "$cPort" && -z "$wsPort" ]]; then
        return
    fi

    if [[ -z "$pCurrentIp" || -z "$rPort" || -z "$wPort" || -z "$cPort" || -z "$wsPort" ]]; then
        help
    fi

    NON_INTERACTIVE=true
}

# read inputs to create network
function readInputs(){   
    
    if [ -z "$NON_INTERACTIVE" ]; then

        getInputWithDefault '请输入节点的IP地址' "" pCurrentIp $RED
        
        getInputWithDefault '请输入节点的RPC端口' 22000 rPort $GREEN
        
        getInputWithDefault '请输入节点的网络监听端口' $((rPort+1)) wPort $GREEN
        
        getInputWithDefault '请输入Constellation节点的端口号' $((wPort+1)) cPort $GREEN

        getInputWithDefault '请输入节点的WS端口' $((cPort+1)) wsPort $GREEN
            
    fi
    role="Unassigned"
	
    #append values in Setup.conf file 
    echo 'CURRENT_IP='$pCurrentIp > ./setup.conf
    echo 'RPC_PORT='$rPort >> ./setup.conf
    echo 'WHISPER_PORT='$wPort >> ./setup.conf
    echo 'CONSTELLATION_PORT='$cPort >> ./setup.conf
    echo 'WS_PORT='$wsPort >>  ./setup.conf
        
    echo 'NETWORK_ID='$net >>  ./setup.conf
    echo 'RAFT_ID='1 >>  ./setup.conf
    echo 'NODENAME='$nodeName >> ./setup.conf
    echo 'ROLE='$role >> ./setup.conf
    echo 'CONTRACT_ADD=' >> ./setup.conf
    echo 'REGISTERED=' >> ./setup.conf
    echo 'MODE=ACTIVE' >> ./setup.conf
    echo 'STATE=I' >> ./setup.conf
    PATTERN="s/r_Port/${rPort}/g"
    sed -i $PATTERN node/start_${nodeName}.sh
    PATTERN="s/w_Port/${wPort}/g"
    sed -i $PATTERN node/start_${nodeName}.sh
    PATTERN="s/nodeIp/${pCurrentIp}/g"
    sed -i $PATTERN node/start_${nodeName}.sh
}


function generateConstellationConf() {
    PATTERN1="s/#CURRENT_IP#/${pCurrentIp}/g"
    PATTERN2="s/#C_PORT#/$cPort/g"
    PATTERN3="s/#mNode#/$nodeName/g"

    sed -i "$PATTERN1" node/$nodeName.conf
    sed -i "$PATTERN2" node/$nodeName.conf
    sed -i "$PATTERN3" node/$nodeName.conf
}

function migrateToTessera() {
    
    pushd node
    . ./migrate_to_tessera.sh "http://${pCurrentIp}:$cPort/"  >> /dev/null 2>&1
    popd
}

function main(){
    net=#netid#
    nodeName=#nodename#

    readParameters $@

    if [ ! -f setup.conf ]; then

        readInputs
        generateConstellationConf
        
        if [ ! -z $tessera ]; then
            migrateToTessera
            PRIVACY="TESSERA"
        fi
        
        publickey=$(cat node/keys/$nodeName.pub)
        echo 'PUBKEY='$publickey >> ./setup.conf

        echo -e '****************************************************************************************************************'

        echo -e '\e[1;32m成功创建节点 \e[0m'$nodeName
        echo -e '\e[1;32m使用以下接口发送交易 \e[0m'$pCurrentIp:$rPort
        echo -e '\e[1;32m对于隐私交易，使用 \e[0m'$publickey

        echo -e '****************************************************************************************************************'
        
    fi
    
}
main $@
