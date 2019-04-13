pragma solidity >=0.4.21 <0.6.0;

contract SaveE {

    struct Abstract {
        uint timestamp;
        address sender;
        bytes32 hash;
        string extend;
    }

    mapping(bytes32 => Abstract) abstractData;
    mapping(address => bool) public allowedMap;
    address[] public allowedArray;

    event AddressAllowed(address _handler, address _address);
    event AddressDenied(address _handler, address _address);
    event DataSaved(address indexed _handler, uint timestamp, address indexed sender, bytes32 hash);
    event StorageSaved(address handler, bytes32 indexed hashKey, uint timestamp, string extend);

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

    function setData(bytes32 _key, uint timestamp, address sender, bytes32 hash, string memory extend) allow public {
        abstractData[_key].timestamp = timestamp;
        abstractData[_key].sender = sender;
        abstractData[_key].hash = hash;
		abstractData[_key].extend = extend;
        emit DataSaved(msg.sender, timestamp, sender, hash);
    }


    function getData(bytes32 key) public view returns(uint timestamp, address sender, bytes32 hashKey, string memory extend) {

        return(abstractData[key].timestamp, abstractData[key].sender, abstractData[key].hash, abstractData[key].extend);
    }

    function saveData(bytes32 hashKey, string memory extend) public {
        setData(hashKey, block.timestamp, msg.sender, hashKey, extend);

        emit StorageSaved(msg.sender, hashKey, block.timestamp, extend);
    }
}
