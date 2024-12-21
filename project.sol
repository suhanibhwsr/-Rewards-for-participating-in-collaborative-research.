// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CollaborativeResearchRewards {
    
    struct Researcher {
        address wallet;
        string name;
        uint256 totalRewards;
    }

    mapping(address => Researcher) public researchers;
    mapping(address => bool) public isResearcher;

    address public owner;
    uint256 public totalRewardPool;

    event ResearcherAdded(address indexed researcher, string name);
    event RewardDistributed(address indexed researcher, uint256 amount);
    event FundsAdded(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyResearcher() {
        require(isResearcher[msg.sender], "Only a registered researcher can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addResearcher(address _wallet, string memory _name) public onlyOwner {
        require(!isResearcher[_wallet], "Researcher already exists.");

        researchers[_wallet] = Researcher({
            wallet: _wallet,
            name: _name,
            totalRewards: 0
        });

        isResearcher[_wallet] = true;

        emit ResearcherAdded(_wallet, _name);
    }

    function addFunds() public payable onlyOwner {
        require(msg.value > 0, "Funds must be greater than zero.");

        totalRewardPool += msg.value;

        emit FundsAdded(msg.value);
    }

    function distributeReward(address _researcher, uint256 _amount) public onlyOwner {
        require(isResearcher[_researcher], "Recipient must be a registered researcher.");
        require(_amount > 0, "Reward amount must be greater than zero.");
        require(_amount <= totalRewardPool, "Insufficient reward pool.");

        researchers[_researcher].totalRewards += _amount;
        totalRewardPool -= _amount;

        payable(_researcher).transfer(_amount);

        emit RewardDistributed(_researcher, _amount);
    }

    function getResearcherDetails(address _researcher) public view returns (string memory, uint256) {
        require(isResearcher[_researcher], "Researcher not found.");
        Researcher memory researcher = researchers[_researcher];
        return (researcher.name, researcher.totalRewards);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
