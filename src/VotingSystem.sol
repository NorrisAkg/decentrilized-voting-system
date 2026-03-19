// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error VotingSystem__NotTheOwner(address caller);
error VotingSystem__VotingIsNotPending();
error VotingSystem__VotingIsNotOpened();
error VotingSystem__VotingIsNotClosed();

contract VotingSystem {
    event VoteCast(address indexed voter, uint256 indexed candidateId);

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
    VotingStatus private votingStatus;

    constructor() {
        owner = msg.sender;
        votingStatus = VotingStatus.PENDING;
    }

    function _onlyOwner() private view {
        if (msg.sender != owner) {
            revert VotingSystem__NotTheOwner(msg.sender);
        }
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function getVotingStatus() private view returns (VotingStatus) {
        return votingStatus;
    }

    function _votingIsPending() private view {
        if (getVotingStatus() != VotingStatus.PENDING) {
            revert VotingSystem__VotingIsNotPending();
        }
    }

    function _votingIsOpened() private view {
        if (getVotingStatus() != VotingStatus.OPENED) {
            revert VotingSystem__VotingIsNotOpened();
        }
    }

    function _votingIsClosed() private view {
        if (getVotingStatus() != VotingStatus.CLOSED) {
            revert VotingSystem__VotingIsNotClosed();
        }
    }

    modifier votingIsPending() {
        _votingIsPending();
        _;
    }

    modifier votingIsClosed() {
        _votingIsClosed();
        _;
    }

    modifier votingIsOpened() {
        _votingIsOpened();
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

        emit VoteCast(msg.sender, candidateId); // emit event
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
