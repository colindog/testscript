#!/bin/bash

source qm.variables
source node/common.sh

function readParameters() {
    
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -d|--detached)
            detached="true"
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

}

# docker command to create a network
function startNode(){
    docker kill $NODENAME 2> /dev/null && docker rm $NODENAME 2> /dev/null

    docker run $DOCKER_FLAG --rm --name $NODENAME \
            -v $(pwd):/home  -w /home/node  \
            -v $(pwd)/node/contracts:/root/quorum-maker/contracts \
            -p $RPC_PORT:$RPC_PORT \
            -p $WHISPER_PORT:$WHISPER_PORT \
            -p $WHISPER_PORT:$WHISPER_PORT/udp \
            -p $CONSTELLATION_PORT:$CONSTELLATION_PORT \
            -p $RAFT_PORT:$RAFT_PORT \
            -p $WS_PORT:$WS_PORT \
            -e CURRENT_NODE_IP=$CURRENT_IP \
            -e R_PORT=$RPC_PORT \
            -e W_PORT=$WHISPER_PORT \
            -e C_PORT=$CONSTELLATION_PORT \
            -e RA_PORT=$RAFT_PORT \
            -e WS_PORT=$WS_PORT \
            -e NETID=$NETWORK_ID \
            -e NODE_NAME=$NODENAME \
            $dockerImage ./start_${NODENAME}.sh
}

function main(){
    
    docker run -it --rm -v $(pwd):/home  -w /home  \
              $dockerImage node/pre_start_check.sh $@

    if [ -f setup.conf ]; then
         source setup.conf
    fi

    if [ -z $NETWORK_ID ]; then
        exit
    fi

    readParameters $@

    if [[ -z "$detached" ]]; then 
	    DOCKER_FLAG="-it"
    else
	    DOCKER_FLAG="-d"
    fi 	

    startNode
}
main $@
