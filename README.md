## Quickstart

```
git clone https://github.com/monokrohm/fund-me-solidity.git
cd fund-me-solidity
forge build
```

## Foundry Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

<b></b>  
Simulate Sepolia chain using anvil

```shell
$ forge test --fork-url $SEPOLIA_URL

$ forge test --mt <function> -vvvvv --fork-url <rpc_url>
```

### Coverage

See how much of the contract is being tested

```shell
$ forge coverage --fork-url/--rpc-url <rpc_url>
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Chisel

Solidity in terminal

```shell
$ chisel
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployFundMe.s.sol --rpc-url <rpc_url> --private-key <your_private_key> --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Scripts

Run scripts after deploying to a testnet or local net

```shell
$ cast send <FUNDME_CONTRACT_ADDRESS> "fund()" --value 0.1ether --private-key <PRIVATE_KEY>
```

<b></b>  
Run a specific contract in a script

```shell
$ forge script script/Interactions.s.sol:FundFundMe --rpc-url <rpc_url>  --private-key <your_private_key>  --broadcast
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
