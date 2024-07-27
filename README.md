# NFT Staking Protocol

## Overview

The NFT Staking Protocol is for staking the NFT and claiming the rewards for staking. In this protocol, rewards will be calculated per block that means user will get the amount of rewards in ERC20 token (Number of blocks user stake the NFT * rewards per block set by the protocol). User can stake only NFTs which are allowed by the protocol. When user wants to unstake the NFT, user have to wait for the 1 day unbonding period. After completing the unbonding period, user can withdraw the NFT and calim the rewards.

## Features

- **NFT Staking:** Users can stake the NFT for generating rewards in terms of ERC20 Token.
- **Reward System:** Rewards for staking NFT will be per block of staking period.
- **Tested with Foundry Framework:** Comprehensive testing of the protocol functionalities using the Foundry framework.
- **Deployed on Sepolia Test Network:** The contract is deployed and operational on the Sepolia test network.

## Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) - The framework used for development and testing.
- Sepolia test network access - For deployment and interaction with the contract.

### Installation

- **Clone the Repository**
   
      git clone https://github.com/neel10410/NFT-Staking-Protocol.git
      cd staking
   
- **Install Dependencies**
      
      forge install
      forge install OpenZeppelin/openzeppelin-contracts --no-commit
      forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit

- **Compile the Contracts**
  
      forge build 

### Deployment
- **Deploy the contract to the Sepolia test network:**

- **Configure Network**   
      Set up your Sepolia network configuration in .envTemplate as .env file.

- **Deploy Contract**
  
      forge script script/Deploy.s.sol:Deploy --broadcast --verify  -vvvv

- **Deployed Address**
      
    | Contract Name                | Address                                                                                                                       |
    | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
    | Staking Proxy                | [0x66Fa8fb7BE4C19434D8481294856b965cb804a67](https://sepolia.etherscan.io/address/0x66fa8fb7be4c19434d8481294856b965cb804a67) |
    | Staking NFT Implementation-1 | [0x1D41d75042747574d4943800c7184A5993F638d4](https://sepolia.etherscan.io/address/0x1d41d75042747574d4943800c7184a5993f638d4) |
    | Staking NFT Implementation-2 | [0x331E7758A9188d8afc5FA3883Ad7EF238169a119](https://sepolia.etherscan.io/address/0x331e7758a9188d8afc5fa3883ad7ef238169a119) |


## Testing
The protocol functionalities are tested using the Foundry framework. To run the tests:

    forge test

- **Test Coverage**
      
      Ran 10 tests for test/StakingTest.t.sol:StakingTest
      [PASS] testAllowNft() (gas: 42511)
      [PASS] testClaimRewards() (gas: 267170)
      [PASS] testIsPauseAtStart() (gas: 16081)
      [PASS] testPauseStaking() (gas: 33884)
      [PASS] testRewardPerBlockAtStart() (gas: 15958)
      [PASS] testStake() (gas: 183745)
      [PASS] testStakeRquireStatements() (gas: 232866)
      [PASS] testUnstake() (gas: 223025)
      [PASS] testUpdateRewards() (gas: 25993)
      [PASS] test_authorizeUpgrade() (gas: 21963)
      Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 29.42ms (24.03ms CPU time)

      Ran 1 test for script/Deploy.s.sol:Deploy
      [PASS] testScript() (gas: 3218192)
      Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 5.77s (5.76s CPU time)

      Ran 2 test suites in 5.80s (5.79s CPU time): 11 tests passed, 0 failed, 0 skipped (11 total tests)
      | File            | % Lines         | % Statements    | % Branches      | % Funcs         |
      | --------------- | --------------- | --------------- | --------------- | --------------- |
      | src/MockNft.sol | 100.00% (1/1)   | 100.00% (1/1)   | 100.00% (0/0)   | 100.00% (2/2)   |
      | src/Staking.sol | 100.00% (42/42) | 100.00% (44/44) | 100.00% (16/16) | 100.00% (11/11) |
      | Total           | 100.00% (43/43) | 100.00% (45/45) | 100.00% (16/16) | 100.00% (13/13) |



## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
For any inquiries or support, please contact [neelshah1041@gmail.com].