# OrangeProtocol - Sovereign Bitcoin Governance

[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-orange)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-purple)](https://stacks.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 🎯 Overview

OrangeProtocol is a comprehensive decentralized autonomous organization (DAO) built on the Stacks blockchain, enabling Bitcoin-native governance and community-driven treasury management. The protocol provides a trustless framework for collective decision-making, fund allocation, and investment tracking while maintaining Bitcoin's decentralized ethos.

## ✨ Key Features

- **🗳️ Bitcoin-Native Governance**: STX-based voting power with sophisticated proposal management
- **🔄 Dynamic Delegation System**: Flexible vote management with expirable delegations
- **🚨 Emergency Controls**: Protocol security with pause mechanisms and admin privileges
- **⚙️ Configurable Parameters**: Adaptable governance settings for different communities
- **💰 Automated Returns**: Investment return distribution system with proportional claims
- **🔒 Multi-Tier Validation**: Comprehensive proposal validation and execution pipeline
- **📊 Transparent Treasury**: Full audit trail for all fund movements and decisions

## 🏗️ Architecture

### Core Components

1. **Governance Engine**: Proposal creation, voting, and execution
2. **Treasury Management**: Secure fund handling with multi-signature controls
3. **Delegation System**: Vote power delegation with time-based expiry
4. **Return Distribution**: Automated profit sharing for successful investments
5. **Emergency Controls**: Circuit breakers and admin functions for security
6. **Parameter Management**: Dynamic configuration updates

### Smart Contract Structure

```text
orange-protocol.clar
├── Error Constants        # Comprehensive error handling
├── Data Variables        # Core protocol state
├── Governance Parameters # Configurable settings
├── Data Maps            # Member, proposal, and vote storage
├── Emergency Controls   # Security mechanisms
├── Delegation System    # Vote power management
├── Proposal Management  # Governance workflow
├── Return Distribution  # Investment returns
└── Read-Only Functions  # State queries
```

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development toolkit
- [Node.js](https://nodejs.org/) v16+ for testing framework
- [Stacks Wallet](https://wallet.hiro.so/) for interaction

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/makun-creator/orange-protocol.git
   cd orange-protocol
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify contract**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Local Development

Start a local development environment:

```bash
clarinet console
```

Deploy to local testnet:

```bash
clarinet integrate
```

## 📋 Usage

### Creating a Proposal

```clarity
;; Create a funding proposal
(contract-call? .orange-protocol create-proposal
  "Infrastructure Upgrade"
  "Upgrade core infrastructure for improved performance"
  u5000000  ;; 5 STX
  'SP1234...ABCD  ;; Target recipient
)
```

### Voting on Proposals

```clarity
;; Vote on proposal (implementation needed)
(contract-call? .orange-protocol vote
  u1        ;; Proposal ID
  true      ;; Support (true/false)
  u1000000  ;; Voting power to use
)
```

### Delegating Voting Power

```clarity
;; Delegate votes to trusted member
(contract-call? .orange-protocol delegate-votes
  'SP1234...DELEGATE  ;; Delegate address
  u500000            ;; Amount to delegate
  u1000              ;; Expiry block
)
```

### Claiming Returns

```clarity
;; Claim returns from successful investment
(contract-call? .orange-protocol claim-returns
  u1  ;; Pool ID
)
```

## ⚙️ Configuration

### Governance Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `proposal-fee` | 0.1 STX | Fee to create proposals |
| `min-proposal-amount` | 1 STX | Minimum proposal amount |
| `max-proposal-amount` | 1000 STX | Maximum proposal amount |
| `voting-delay` | 100 blocks | Delay before voting starts |
| `voting-period` | 144 blocks | Duration of voting (~1 day) |
| `timelock-period` | 72 blocks | Execution delay (~12 hours) |
| `quorum-threshold` | 50% | Minimum participation |
| `super-majority` | 66.7% | Required for critical changes |

### Updating Parameters

```clarity
;; Update governance parameters (admin only)
(contract-call? .orange-protocol update-dao-parameters {
  proposal-fee: u200000,
  min-proposal-amount: u2000000,
  ;; ... other parameters
})
```

## 🔐 Security Features

### Emergency Controls

- **Emergency State**: Protocol-wide pause mechanism
- **Admin Functions**: Multi-signature administrative controls  
- **Parameter Validation**: Comprehensive input sanitization
- **Reentrancy Protection**: Safe external call patterns

### Access Control

- **Member Validation**: Verified participant requirements
- **Voting Power**: STX-based stake weighting
- **Delegation Limits**: Controlled vote power transfer
- **Time Locks**: Delayed execution for security

## 🧪 Testing

The protocol includes comprehensive test coverage:

```bash
# Run all tests
npm test

# Run specific test file
npm test -- orange-protocol.test.ts

# Run with verbose output
npm test -- --verbose
```

### Test Categories

- **Unit Tests**: Individual function validation
- **Integration Tests**: Cross-component workflows
- **Security Tests**: Attack vector prevention
- **Edge Cases**: Boundary condition handling

## 📊 Monitoring & Analytics

### Key Metrics

- **Total Value Locked (TVL)**: Treasury balance and delegated amounts
- **Governance Activity**: Proposal creation and voting rates
- **Member Engagement**: Active participant metrics
- **Return Distribution**: Investment performance tracking

### Read-Only Functions

```clarity
;; Query functions for monitoring
(get-treasury-balance)           ;; Current treasury amount
(get-dao-parameters)            ;; Current governance settings
(get-member-info 'SP123...)     ;; Member details
(get-proposal-by-id u1)         ;; Proposal information
```

## 🛣️ Roadmap

### Phase 1: Core Governance ✅

- [x] Proposal creation and voting
- [x] Treasury management
- [x] Member registry

### Phase 2: Advanced Features ✅

- [x] Delegation system
- [x] Return distribution
- [x] Emergency controls

### Phase 3: Enhancements (In Progress)

- [ ] Quadratic voting mechanisms
- [ ] Multi-signature proposals
- [ ] Cross-chain integrations
- [ ] Advanced analytics dashboard

### Phase 4: Ecosystem Integration

- [ ] DeFi protocol integrations
- [ ] NFT governance tokens
- [ ] Layer 2 scaling solutions

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

### Code Standards

- Follow Clarity best practices
- Include comprehensive tests
- Document all public functions
- Maintain backwards compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
