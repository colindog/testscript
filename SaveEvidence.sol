pragma solidity >=0.4.21 <0.6.0;

contract SaveEvidence {

    struct Abstract {
        uint timestamp;
        address sender;
        bytes32 hash;
        byte[512] extend;
    }

    mapping(bytes32 => Abstract) abstractData;
    mapping(address => bool) public allowedMap;
    address[] public allowedArray;

    event AddressAllowed(address _handler, address _address);
    event AddressDenied(address _handler, address _address);
    event DataSaved(address indexed _handler, uint timestamp, address indexed sender, bytes32 hash);
    event ExtendSaved(address indexed _handler, byte[512] extend);
    event StorageSaved(address handler, bytes32 indexed hashKey, uint timestamp, byte[512] extend);

    constructor() public {
        allowedMap[msg.sender] = true;
        allowedArray.push(msg.sender);
    }

    modifier allow() {
        require(allowedMap[msg.sender] == true);
        _;
    }

    function allowAccess(address _address) allow public {
        allowedMap[_address] = true;
        allowedArray.push(_address);
        emit AddressAllowed(msg.sender, _address);
    }

    function denyAccess(address _address) allow public {
        allowedMap[_address] = false;
        emit AddressDenied(msg.sender, _address);
    }

    function setData(bytes32 _key, uint timestamp, address sender, bytes32 hash) allow public {
        abstractData[_key].timestamp = timestamp;
        abstractData[_key].sender = sender;
        abstractData[_key].hash = hash;
        emit DataSaved(msg.sender, timestamp, sender, hash);
    }

    function setExtend(bytes32 _key, byte[512] memory extend) allow public {
            for (uint256 i; i < 512; i++) {
                abstractData[_key].extend[i] = extend[i];
            }
            emit ExtendSaved(msg.sender, extend);
    }

    function getData(bytes32 key) public view returns(uint timestamp, address sender, bytes32 hashKey, string memory extend) {
        byte[512] memory extendByte;

        (timestamp, sender, hashKey, extendByte) = (abstractData[key].timestamp, abstractData[key].sender, abstractData[key].hash, abstractData[key].extend);

        bytes memory bytesArray = new bytes(512);
        for (uint256 i; i < 512; i++) {
            bytesArray[i] = extendByte[i];
        }

        extend = string(bytesArray);
        return(timestamp, sender, hashKey, extend);
    }

    function saveData(bytes32 hashKey, byte[512] memory extend) public {
        setData(hashKey, block.timestamp, msg.sender, hashKey);
        setExtend(hashKey, extend);

        emit StorageSaved(msg.sender, hashKey, block.timestamp, extend);
    }
}
