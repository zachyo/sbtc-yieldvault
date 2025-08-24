# sBTC YieldVault

A Clarity smart contract that wraps Hermetica's USDh stablecoin functionality, enabling sBTC as collateral to mint USDh and earn up to 25% APY yields.

## Overview

sBTC YieldVault is a wrapper contract built on the Stacks blockchain that integrates with Hermetica's USDh stablecoin protocol. Users can deposit sBTC as collateral to mint USDh tokens while earning yield through Hermetica's 25% APY mechanism.

### Key Features

- **sBTC Collateral**: Use sBTC tokens as collateral for minting USDh
- **25% APY Yield**: Earn up to 25% annual percentage yield on USDh holdings
- **150% Minimum Collateral Ratio**: Secure over-collateralization requirement
- **Proportional Redemption**: Redeem USDh for proportional sBTC amounts
- **Yield Accrual**: Automatic yield calculation and claiming
- **Admin Controls**: Pause functionality and ownership management
- **Comprehensive Events**: Detailed logging for all operations

## Contract Architecture

### Core Functions

#### Public Functions

- `mint-usdh(sbtc-amount, usdh-amount)` - Mint USDh using sBTC collateral
- `redeem-usdh(usdh-amount)` - Redeem USDh for sBTC collateral
- `claim-yield()` - Claim accrued yield without redeeming collateral
- `set-contract-paused(paused)` - Admin function to pause/unpause contract
- `transfer-ownership(new-owner)` - Transfer contract ownership

#### Read-Only Functions

- `get-user-position(user)` - Get user's collateral and debt position
- `get-collateral-ratio(user)` - Calculate user's collateral ratio
- `get-pending-yield(user)` - Calculate pending yield for user
- `get-contract-stats()` - Get global contract statistics
- `is-position-healthy(user)` - Check if position meets minimum requirements
- `get-contract-info()` - Get contract version and metadata

### Constants

- **MIN_COLLATERAL_RATIO**: 15000 (150% minimum collateral ratio)
- **ANNUAL_YIELD_RATE**: 2500 (25% APY in basis points)
- **BLOCKS_PER_YEAR**: 52560 (assuming 10-minute block times)

### Error Codes

- `ERR_NOT_AUTHORIZED (u1)` - Unauthorized access
- `ERR_INSUFFICIENT_BALANCE (u2)` - Insufficient balance for operation
- `ERR_INVALID_AMOUNT (u3)` - Invalid amount provided
- `ERR_CONTRACT_CALL_FAILED (u4)` - External contract call failed
- `ERR_POSITION_NOT_FOUND (u5)` - User position not found
- `ERR_INSUFFICIENT_COLLATERAL (u6)` - Below minimum collateral ratio
- `ERR_LIQUIDATION_THRESHOLD (u7)` - Position at liquidation risk
- `ERR_PAUSED (u8)` - Contract is paused

## Getting Started

### Prerequisites

- [Clarinet](https://docs.hiro.so/stacks/clarinet) v3.5.0+
- Node.js v16+
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sbtc-yieldvault
```

2. Install dependencies:
```bash
npm install
```

3. Verify contract syntax:
```bash
clarinet check
```

### Development

#### Running Tests

```bash
# Run all tests
npm test

# Run Clarinet console for interactive testing
clarinet console
```

#### Testing Example (100 Test Coins)

```clarity
;; Check initial contract stats
(contract-call? .yieldvault-wrapper get-contract-stats)

;; Mint 50 USDh with 100 sBTC (200% collateral ratio)
(contract-call? .yieldvault-wrapper mint-usdh u100 u50)

;; Check user position
(contract-call? .yieldvault-wrapper get-user-position tx-sender)

;; Advance blocks to accrue yield
::advance_chain_tip 1000

;; Check pending yield
(contract-call? .yieldvault-wrapper get-pending-yield tx-sender)

;; Redeem 25 USDh
(contract-call? .yieldvault-wrapper redeem-usdh u25)
```

### Deployment

#### Devnet Deployment

1. Generate deployment plan:
```bash
clarinet deployments generate --devnet
```

2. Start devnet:
```bash
clarinet devnet start
```

3. Apply deployment:
```bash
clarinet deployments apply --devnet
```

#### Testnet/Mainnet Deployment

1. Generate deployment plan:
```bash
clarinet deployments generate --testnet
# or
clarinet deployments generate --mainnet
```

2. Apply deployment with your wallet:
```bash
clarinet deployments apply --testnet
# or
clarinet deployments apply --mainnet
```

## Usage Examples

### Basic Minting

```clarity
;; Mint 50 USDh with 100 sBTC collateral (200% ratio)
(contract-call? .yieldvault-wrapper mint-usdh u100 u50)
;; Returns: (ok {collateral-ratio: u20000, sbtc-deposited: u100, usdh-minted: u50})
```

### Checking Position Health

```clarity
;; Check if position meets minimum requirements
(contract-call? .yieldvault-wrapper is-position-healthy 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
;; Returns: true or false
```

### Yield Management

```clarity
;; Check pending yield
(contract-call? .yieldvault-wrapper get-pending-yield tx-sender)

;; Claim accrued yield
(contract-call? .yieldvault-wrapper claim-yield)
```

## Integration Points

### Hermetica USDh Integration

The contract includes placeholder integration points for Hermetica's USDh protocol:

```clarity
;; TODO: Call Hermetica's mint function
;; (try! (contract-call? .hermetica-usdh mint usdh-amount caller))

;; TODO: Burn USDh tokens
;; (try! (contract-call? .hermetica-usdh burn usdh-amount caller))
```

### sBTC Token Integration

Placeholder integration for sBTC token transfers:

```clarity
;; TODO: Transfer sBTC from user to contract
;; (try! (contract-call? .sbtc-token transfer sbtc-amount caller (as-contract tx-sender) none))
```

## Security Features

- **Minimum Collateral Ratio**: 150% requirement prevents under-collateralization
- **Pause Mechanism**: Emergency stop functionality for admin
- **Access Controls**: Owner-only functions for critical operations
- **Input Validation**: Comprehensive validation of all user inputs
- **Event Logging**: Detailed events for transparency and monitoring

## Monitoring & Analytics

### Contract Statistics

```clarity
(contract-call? .yieldvault-wrapper get-contract-stats)
;; Returns comprehensive contract metrics including:
;; - total-sbtc-locked
;; - total-usdh-minted  
;; - contract-paused status
;; - yield parameters
```

### Event Tracking

All operations emit detailed events for monitoring:

- **mint-usdh**: Collateral deposits and USDh minting
- **redeem-usdh**: USDh redemption and collateral withdrawal
- **claim-yield**: Yield claiming events
- **contract-paused-changed**: Admin pause/unpause actions
- **ownership-transferred**: Ownership change events

## Roadmap

### Phase 4: Frontend Development
- React application for user interface
- Wallet integration (Leather, Xverse)
- Real-time position monitoring
- Yield tracking dashboard

### Phase 5: Production Readiness
- Security audit
- Mainnet deployment
- Documentation completion
- Community testing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

[MIT License](LICENSE)

## Support

For questions and support:
- Create an issue in this repository
- Join our Discord community
- Check the [Stacks documentation](https://docs.stacks.co)

