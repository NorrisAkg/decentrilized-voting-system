// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {VotingSystem, VotingSystem__NotTheOwner, VotingSystem__VotingIsNotPending} from "../src/VotingSystem.sol";

contract VotingSystemTest is Test {
    VotingSystem votingSystem;
    address owner = makeAddr("owner");
    address voter1 = makeAddr("Jon");
    address voter2 = makeAddr("Jane");
    address voter3 = makeAddr("Henri");
    address voter4 = makeAddr("Mathew");

    function setUp() public {
        vm.prank(owner);
        votingSystem = new VotingSystem();
    }

    function testCandidateAddingSuccess() external {
        string memory candidateName = "Alice";
        vm.prank(owner);
        votingSystem.addCandidate(candidateName);

        vm.prank(voter1);
        VotingSystem.Candidate memory candidate = votingSystem.getCandidate(0);

        assertEq(candidate.name, candidateName);
        assertEq(candidate.votes, 0);
    }

    function testAddingCandidateRevertWhenIsNotOwner() external {
        string memory candidateName = "Alice";

        vm.prank(voter1);

        vm.expectRevert(
            abi.encodeWithSelector(VotingSystem__NotTheOwner.selector, voter1)
        );
        votingSystem.addCandidate(candidateName);
    }

    function testAddingCandidateRevertWhenVotingIsOpened() external {
        string memory candidateName = "Alice";

        vm.startPrank(owner);
        votingSystem.openVoting();

        vm.expectRevert(VotingSystem__VotingIsNotPending.selector);
        votingSystem.addCandidate(candidateName);
        vm.stopPrank();
    }

    function testVoteSuccess() external {
        string memory candidateName = "Alice";

        vm.startPrank(owner);
        votingSystem.addCandidate(candidateName);
        votingSystem.openVoting(); // Open voting
        vm.stopPrank();

        vm.prank(voter1);
        votingSystem.vote(0);

        VotingSystem.Candidate memory candidate = votingSystem.getCandidate(0);

        assertEq(candidate.votes, 1);
    }

    function makeVote(address voter, uint256 candidateId) private {
        vm.prank(voter);
        votingSystem.vote(candidateId);
    }

    function testGettingWinnerAfterVoting() external {
        string memory firstCandidateName = "Alice";
        string memory secondCandidateName = "Bob";

        vm.startPrank(owner);
        votingSystem.addCandidate(firstCandidateName);
        votingSystem.addCandidate(secondCandidateName);
        votingSystem.openVoting(); // Open voting
        vm.stopPrank();

        makeVote(voter1, 0);
        makeVote(voter2, 0);
        makeVote(voter3, 1);
        makeVote(voter4, 0);

        VotingSystem.Candidate memory firstCandidate = votingSystem
            .getCandidate(0);
        VotingSystem.Candidate memory secondCandidate = votingSystem
            .getCandidate(1);

        assertEq(firstCandidate.votes, 3);
        assertEq(secondCandidate.votes, 1);

        vm.startPrank(owner);
        votingSystem.closeVoting();
        (uint256 winnerId, string memory name, uint256 votes) = votingSystem
            .getWinner();
        vm.stopPrank();

        assertEq(winnerId, 0);
        assertEq(name, firstCandidateName);
        assertEq(votes, 3);
    }
}
