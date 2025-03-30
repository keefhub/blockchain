// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {

    struct Candidate {
        uint8 id;
        bytes32 name;
        uint voteCount;
    }

    mapping(uint8 => Candidate) public candidates;
    mapping(address => bool) public voters;

    uint8 public candidateCount = 0;
    uint public startTime;
    uint public endTime;

    event VoteEvent(uint indexed _candidateId);

    constructor(uint _durationInMinutes) {
        startTime = block.timestamp;
        endTime = startTime + (_durationInMinutes * 1 minutes);

        addCandidate(stringToBytes32("Bob"));
        addCandidate(stringToBytes32("Alice"));
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory temp = bytes(source);
        require(temp.length <= 32, "String too long");
        assembly {
            result := mload(add(source, 32))
        }
    }

    function addCandidate(bytes32 _name) private {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, 0);
    }

    function Vote(uint8 _candidateid) public {
        require(!voters[msg.sender], "You have already voted");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting is not allowed at this time");
        require(_candidateid > 0 && _candidateid <= candidateCount, "You have entered an invalid id");
        
        voters[msg.sender] = true;
        candidates[_candidateid].voteCount++;

        emit VoteEvent(_candidateid);
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory candidateArray = new Candidate[](candidateCount);
        for (uint8 i = 1; i <= candidateCount; i++) {
            candidateArray[i - 1] = candidates[i];
        }
        return candidateArray;
    }

    function getwinner() public view returns (string memory) {
        require(block.timestamp > endTime, "Voting is still ongoing, results will be available after voting ends");
        
        uint maxVotes = 0;
        uint8 leadingCandidateId = 0;

        for (uint8 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                leadingCandidateId = i;
            }
        }

        if (leadingCandidateId == 0) {
            return "No votes have been casted";
        }

        return string(abi.encodePacked(candidates[leadingCandidateId].name));
    }
}

//after gas optimization