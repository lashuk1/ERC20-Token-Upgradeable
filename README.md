# MyTokenProject

This project is an upgradeable ERC20 token using the UUPS proxy pattern, written in Solidity `^0.8.28` and tested with Foundry.

## Features

- Minting and burning with access control (`MINTER_ROLE`, `BURNER_ROLE`)
- Upgradeable using OpenZeppelin UUPS proxy
- Written and tested using Foundry

## Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (optional, for installing dependencies)
- Git

## Usage

### Build

```bash
forge build
```

### Run Tests

```bash
forge test -vvv
```

### Format Code

```bash
forge fmt
```

## Project Structure

- `src/` - Contracts (`MyToken.sol`, `MyTokenV2.sol`)
- `test/` - Test files using Foundry
- `lib/` - External dependencies (OpenZeppelin)

## License

MIT
