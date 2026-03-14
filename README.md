# 🗳️ Decentralized Voting System

A transparent, tamper-proof voting smart contract built with Solidity and Foundry.

---

## Overview

This project implements a decentralized voting system on the EVM. Once deployed, the contract is fully autonomous — no intermediary can alter votes, manipulate results, or censor participants. Every vote is permanently recorded on-chain and publicly verifiable.

---

## Features

- 👤 **Owner-controlled administration** — only the deployer can manage the voting lifecycle
- 📋 **Candidate registration** — candidates are added before the vote opens
- 🗳️ **One address, one vote** — duplicate voting is prevented at the protocol level
- 📊 **Real-time results** — anyone can query live standings at any time
- 🏆 **Automatic winner resolution** — the leading candidate is returned on demand

---

## Voting Lifecycle

```
PENDING ──► OPEN ──► CLOSED
   │           │
   │           └── Voters can cast their vote
   │
   └── Owner can add candidates
```

| State     | Who can act | Allowed actions             |
| --------- | ----------- | --------------------------- |
| `PENDING` | Owner       | Add candidates, open voting |
| `OPENED`  | Anyone      | Cast a vote                 |
| `OPENED`  | Owner       | Close voting                |
| `CLOSED`  | Anyone      | Query winner                |

---

## Smart Contract

**`src/VotingSystem.sol`**

| Function              | Access     | Description                          |
| --------------------- | ---------- | ------------------------------------ |
| `addCandidate(name)`  | Owner only | Register a candidate (PENDING state) |
| `openVoting()`        | Owner only | Transition to OPENED state           |
| `closeVoting()`       | Owner only | Transition to CLOSED state           |
| `vote(candidateId)`   | Anyone     | Cast a vote for a candidate          |
| `getWinner()`         | Anyone     | Returns the leading candidate        |
| `getCandidate(id)`    | Anyone     | Returns candidate data by index      |
| `getCandidateCount()` | Anyone     | Returns total number of candidates   |

---

## Tech Stack

- [Solidity](https://soliditylang.org/) `^0.8.24`
- [Foundry](https://getfoundry.sh/) — compile, test, deploy

---

## Getting Started

### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
anvil --version
cast --version
```

### Install & Build

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
forge build
```

### Run Tests

```bash
forge test
```

Expected output:

```
[PASS] testCandidateAddingSuccess()
[PASS] testAddingCandidateRevertWhenIsNotOwner()
[PASS] testAddingCandidateRevertWhenVotingIsOpened()
[PASS] testVoteSuccess()
[PASS] testGettingWinnerAfterVoting()

5 tests passed, 0 failed
```

### Deploy Locally

```bash
# Start a local node
anvil

# Deploy (in a separate terminal)
forge create src/VotingSystem.sol:VotingSystem \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <ANVIL_PRIVATE_KEY> \
  --broadcast
```

> ⚠️ Never use Anvil private keys on a real network.

---

## Project Structure

```
.
├── src/
│   └── VotingSystem.sol    # Main contract
├── test/
│   └── VotingSystem.t.sol  # Foundry test suite
├── script/                 # Deployment scripts
├── lib/                    # Dependencies
└── foundry.toml            # Foundry config
```

---

## License

MIT