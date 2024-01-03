## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
source .env

#  L1Pool.t.sol

forge test --match-test test_ClaimUSDT -vvv --fork-url sepolia

#  L2Pool.t.sol

forge test --match-test test_WithdrawETHtoOPBridge -vvv --fork-url op
forge test --match-test test_WithdrawETHtoScrollBridge -vvv --fork-url scroll

```

### Deploy

```shell
script ./script/L2Pool.s.sol --rpc-url scroll --broadcast --private-key $Private-key --verify  -vvvvv --etherscan-api-key $api-key --verifier-url https://blockscout.scroll.io/api/ --verifier blockscout