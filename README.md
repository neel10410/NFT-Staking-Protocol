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
      
    | Contract Name | Address                                                                                                                       |
    | ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
    | Staking Proxy | [0xd946f4Ea11BEAc422aEa19451cEF14297D625567](https://sepolia.etherscan.io/address/0xd946f4ea11beac422aea19451cef14297d625567) |
    | Staking NFT   | [0xa4AAFF7d77c0F1FaF37915cf3290b14A0b536565](https://sepolia.etherscan.io/address/0xa4aaff7d77c0f1faf37915cf3290b14a0b536565) |


## Testing
The protocol functionalities are tested using the Foundry framework. To run the tests:

    forge test

- **Test Coverage**
      
      | File            | % Lines         | % Statements    | % Branches      | % Funcs         |
      | --------------- | --------------- | --------------- | --------------- | --------------- |
      | src/MockNft.sol | 100.00% (1/1)   | 100.00% (1/1)   | 100.00% (0/0)   | 100.00% (2/2)   |
      | src/Staking.sol | 100.00% (40/40) | 100.00% (42/42) | 100.00% (16/16) | 100.00% (11/11) |
      | Total           | 100.00% (41/41) | 100.00% (43/43) | 100.00% (16/16) | 100.00% (13/13) |


## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
For any inquiries or support, please contact [neelshah1041@gmail.com].