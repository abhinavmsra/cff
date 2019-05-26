pragma solidity >=0.4.22 <0.7.0;

contract CFF {
    struct CFFChild {
        string name;
        string homeAddress;
        uint dob; // timestamp of birth of a child,
        uint withdrawalBalance;
        uint lockedBalance;
        
        address childAddress;
    }
    
    uint constant ELIIGIBLE_DURATION = 567648000;
    
    mapping(address => CFFChild) public childrenMap;
    
    constructor() public {}

    function createChildRecord(address childAddress, uint dob, string memory name, string memory homeAddress) public {
        childrenMap[childAddress].childAddress = childAddress;
        childrenMap[childAddress].dob = dob;
        childrenMap[childAddress].name = name;
        childrenMap[childAddress].homeAddress = homeAddress;
    }

    function fundAChild(address childAddress) public payable {
        require(
            msg.value > 0, 
            'must be greater than 0'
        );
        
        childrenMap[childAddress].withdrawalBalance += uint(msg.value / 2);
        childrenMap[childAddress].lockedBalance += uint(msg.value / 2);
    }
    
    function retrieveFunds(address childAddress, uint value) public {
        require(
            childrenMap[childAddress].childAddress == msg.sender, 
            'must be the owner'
        );
        
        bool isFullyEligible = (now - childrenMap[childAddress].dob) >= ELIIGIBLE_DURATION;
        uint availableFunds = isFullyEligible ? 
            childrenMap[childAddress].withdrawalBalance + childrenMap[childAddress].lockedBalance : 
            childrenMap[childAddress].withdrawalBalance;
            
        // Must have enough funds
        require(
            availableFunds >= value, 
            'Must have enough funds, locked funds cannot be used'
        );
            
        if (value >= childrenMap[childAddress].withdrawalBalance) {
            uint lockedBalanceReduction = value - childrenMap[childAddress].withdrawalBalance;
           
            childrenMap[childAddress].withdrawalBalance = 0;
            childrenMap[childAddress].lockedBalance -= lockedBalanceReduction;
        } else {
           childrenMap[childAddress].withdrawalBalance -= value; 
        }
    }
}
