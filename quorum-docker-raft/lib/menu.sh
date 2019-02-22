#!/bin/bash

#Menu system for launching appropriate scripts based on user choice
source qm.variables
source lib/common.sh

function banner() {
	printf $CYAN'   ______'$RED'   __      __\n' 
	printf $CYAN'  / ____ \'$RED' |  \    /  |  \n'
	printf $CYAN' / /    \ \'$RED'|   \  /   |  \n'
	printf $CYAN' | |     | '$RED'|    \/    |  \n'
	printf $CYAN' | |     | '$RED'| |\    /| |  \n'
	printf $CYAN' | |     |  \'$RED'| \  / | |  \n'
	printf $CYAN' \ \____/ /\ \'$RED'  \/  | |  \n'
	printf $CYAN'  \______/  \_\'$RED'     |_|  '

	local __version=$(egrep -Eo "[0-9].*" <<< $dockerImage)
	    
	IFS='_'; arrIN=($__version); unset IFS;

	echo -e $GREEN'Version '${arrIN[1]}' Built on CloudChain '${arrIN[0]}'\n'
}

function readParameters() {
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            create)
            option="1"
            shift # past argument            
            ;;
            join)
            option="2"
            shift # past argument            
            ;;
			attach)
            option="3"
            shift # past argument            
            ;;
			dev)
            option="4"
            shift # past argument            
            ;;
            -h|--help)
            help
            
            ;;
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

	if [[ ! -z $option && $option -lt 1 || $option -gt 4 ]]; then 		
		help
	fi
	
	if [ ! -z $option ]; then 		
		NON_INTERACTIVE=true
	fi
    
}

function main() {

	banner
	readParameters $@

	if [ -z "$NON_INTERACTIVE" ]; then
		flagmain=true
		echo -e $YELLOW'操作选择: \n' \
				$GREEN'1) 创建区块链网络 \n' \
				$PINK'2) 加入区块链网络 \n' \
				$CYAN'3) 创建测试区块链网络 \n' \
				$RED'4) 退出' 

		printf $WHITE'option: '$COLOR_END

		read option
	fi

	case $option in
		1)
			lib/create_network.sh $@;;
		2)
			lib/join_network.sh $@;;
		3)
			lib/create_dev_network.sh $@;;
		4)
			flagmain=false	;;
		*)
			echo "Please enter a valid option"	;;
	esac
}

main $@

