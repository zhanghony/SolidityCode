# SolidityCode

这里保存 solidity 的基础语法内容

## 环境搭建

#### 语法代码

```
  $  npm  init -y
  $  npm install --save-dev hardhat
  $  npx hardhat init

```

```
$ npx hardhat help

Hardhat version 2.22.7

Usage: hardhat [GLOBAL OPTIONS] [SCOPE] <TASK> [TASK OPTIONS]

GLOBAL OPTIONS:

  --config              A Hardhat config file.
  --emoji               Use emoji in messages.
  --flamegraph          Generate a flamegraph of your Hardhat tasks
  --help                Shows this message, or a task's help if its name is provided
  --max-memory          The maximum amount of memory that Hardhat can use.
  --network             The network to connect to.
  --show-stack-traces   Show stack traces (always enabled on CI servers).
  --tsconfig            A TypeScript config file.
  --typecheck           Enable TypeScript type-checking of your scripts/tests
  --verbose             Enables Hardhat verbose logging
  --version             Shows hardhat's version.


AVAILABLE TASKS:

  check                 Check whatever you need
  clean                 Clears the cache and deletes all artifacts
  compile               Compiles the entire project, building all artifacts
  console               Opens a hardhat console
  coverage              Generates a code coverage report for tests
  flatten               Flattens and prints contracts and their dependencies. If no file is passed, all the contracts in the project will be flattened.
  gas-reporter:merge
  help                  Prints this message
  node                  Starts a JSON-RPC server on top of Hardhat Network
  run                   Runs a user-defined script after compiling the project
  test                  Runs mocha tests
  typechain             Generate Typechain typings for compiled contracts
  verify                Verifies a contract on Etherscan or Sourcify


AVAILABLE TASK SCOPES:

  ignition              Deploy your smart contracts using Hardhat Ignition
  vars                  Manage your configuration variables

To get help for a specific task run: npx hardhat help [SCOPE] <TASK>


```
 

```
$  npx hardhat node   //本地运行
npx hardhat ignition deploy ./ignition/modules/Lock.ts --network localhost   //合约发布到本地



```



```

$ npm install @openzeppelin/contracts
```