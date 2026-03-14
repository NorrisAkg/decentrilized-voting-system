// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VotingSystem {
    struct Candidate {
        string name;
        uint256 votes;
    }
    enum VotingStatus {
        PENDING,
        OPENED,
        CLOSED
    }

    address private owner;
    Candidate[] public candidates;
    mapping(address => bool) hasVoted;
    VotingStatus public votingStatus;

    constructor() {
        owner = msg.sender;
        votingStatus = VotingStatus.PENDING;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier votingIsPending() {
        require(
            votingStatus == VotingStatus.PENDING,
            "This action can only be performed when the system is pending"
        );
        _;
    }

    modifier votingIsClosed() {
        require(
            votingStatus == VotingStatus.CLOSED,
            "This action can only be performed when the voting is closed"
        );
        _;
    }

    modifier votingIsOpened() {
        require(
            votingStatus == VotingStatus.OPENED,
            "This action can only be performed when the system is opened"
        );
        _;
    }

    function addCandidate(
        string memory _name
    ) public onlyOwner votingIsPending {
        Candidate memory candidate = Candidate({name: _name, votes: 0});

        candidates.push(candidate);
    }

    function openVoting() public onlyOwner votingIsPending {
        votingStatus = VotingStatus.OPENED;
    }

    function closeVoting() public onlyOwner votingIsOpened {
        votingStatus = VotingStatus.CLOSED;
    }

    function vote(uint256 candidateId) external votingIsOpened {
        require(candidateId < candidates.length, "Candidate does not exist");
        require(
            hasVoted[msg.sender] == false,
            "This address has already voted"
        );
        Candidate storage candidate = candidates[candidateId]; // get candidate
        candidate.votes++; // increment candidate votes count
        hasVoted[msg.sender] = true; // set voter has voted
    }

    function getCandidatesCount() external view returns (uint256) {
        return candidates.length;
    }

    function getCandidate(
        uint256 candidateId
    ) public view returns (Candidate memory) {
        return candidates[candidateId];
    }

    function getWinner()
        external
        view
        votingIsClosed
        returns (uint256 candidateId, string memory name, uint256 votes)
    {
        uint256 maxVotesCount = 0;
        uint256 winnerId = 0;
        for (uint256 index = 0; index < candidates.length; index++) {
            Candidate memory candidate = getCandidate(index);
            if (candidate.votes > maxVotesCount) {
                maxVotesCount = candidate.votes;
                winnerId = index;
            }
        }

        Candidate memory winner = getCandidate(winnerId);

        return (winnerId, winner.name, winner.votes);
    }
}
