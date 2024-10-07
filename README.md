# ton-tut

## Project structure

-   `contracts` - source code of all the smart contracts of the project and their dependencies.
-   `wrappers` - wrapper classes (implementing `Contract` from ton-core) for the contracts, including any [de]serialization primitives and compilation functions.
-   `tests` - tests for the contracts.
-   `scripts` - scripts used by the project, mainly the deployment scripts.

## How to use

### Build

`npx blueprint build` or `yarn blueprint build`

### Test

`npx blueprint test` or `yarn blueprint test`

### Deploy or run another script

`npx blueprint run` or `yarn blueprint run`

### Add a new contract

`npx blueprint create ContractName` or `yarn blueprint create ContractName`


## Explanations

#### For more information about working with Stoppable/Resumable functionality, see:
`https://github.com/tact-lang/tact/blob/main/stdlib/libs/stoppable.tact`

#### For more information about working with Ownable functionality, see:
`https://github.com/tact-lang/tact/blob/main/stdlib/libs/ownable.tact`