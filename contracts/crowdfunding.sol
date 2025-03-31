// SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.17;

contract Crowdfunding {
    mapping (address => uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raiseAmount;
    uint public noOfContributors;

    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool isCompleted;
        uint noOfVoters;
        mapping (address => bool) voters;
    }
    mapping (uint => Request) public request;
    uint public numRequest;

    event ContributionReceived(address contributor, uint amount);
    event RequestCreated(string description, address recipient, uint value);
    event PaymentMade(address recipient, uint value);
    event RefundIssued(address contributor, uint amount);

    constructor (uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEther() public payable {
        require(block.timestamp < deadline, "The deadline has passed");
        require(msg.value >= minContribution, "You need to contribute at least 100 wei");

        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raiseAmount += msg.value;
        
        emit ContributionReceived(msg.sender, msg.value);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public {
        require(block.timestamp > deadline && raiseAmount < target, "Refund conditions not met");
        require(contributors[msg.sender] > 0, "You have not contributed");
        
        uint refundAmount = contributors[msg.sender];
        contributors[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
        
        emit RefundIssued(msg.sender, refundAmount);
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyManager {
        Request storage newRequest = request[numRequest];
        numRequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.isCompleted = false;
        newRequest.noOfVoters = 0;
        
        emit RequestCreated(_description, _recipient, _value);
    }

    function voteRequest(uint _requestNo) public {
        require(_requestNo < numRequest, "Request does not exist");
        require(contributors[msg.sender] > 0, "You are not a contributor");
        Request storage thisRequest = request[_requestNo];
        require(thisRequest.voters[msg.sender] == false, "You have already voted");
        
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager {
        require(_requestNo < numRequest, "Request does not exist");
        require(raiseAmount >= target, "Target not met");
        Request storage thisRequest = request[_requestNo];
        require(thisRequest.isCompleted == false, "Already distributed the amount");
        require(thisRequest.noOfVoters > noOfContributors / 2, "Majority support not met");
        require(thisRequest.value <= address(this).balance, "Not enough balance in contract");
        
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.isCompleted = true;
        
        emit PaymentMade(thisRequest.recipient, thisRequest.value);
    }
}
