// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "forge-std/console.sol";

contract Staking is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    IERC721Receiver,
    ReentrancyGuard
{
    // Reward per block
    uint256 public rewardPerBlock;
    // bool to store whether staking is pause or not
    bool public isPause;

    uint256[] public blockNumbers;
    mapping(uint256 blockNum => uint256 reward) public updatedRewards;

    event Staked(address indexed nftAddress, uint256 indexed nftId);
    event Unstaked(address indexed nftAddress, uint256 indexed nftId);
    event ClaimedRewards(address indexed nftAddress, uint256 indexed nftId);

    // userData mapping gives UserInfo struct of nftId of nftAddress
    mapping(address nftAddress => mapping(uint256 nftId => UserInfo))
        public userData;
    // allowNftAddress mapping shows whether given nftAddress is allowed or not
    mapping(address nftAddress => bool allowed) public allowNftAddress;

    // UserInfo struct to store data of user who staked NFT
    struct UserInfo {
        address user;
        uint256 stakeAtBlock;
        uint256 rewardDebt;
        uint256 unstakeAtBlock;
    }

    /**
     * @dev Constructor which disable the initialize function
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev onERC721Received function is used to receive the NFT in the contract
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev Initialize the contract by creating ERC20 token and set the owner of contract
     */
    function initialize() public initializer {
        __ERC20_init("RewardToken", "RT");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        rewardPerBlock = 100;
        blockNumbers.push(block.number);
        updatedRewards[block.number] = 100;
    }

    /**
     * @dev Stake the NFT of user and stotes user info in a stuct
     * @param nftAddress Address of NFT which user wants to stake
     * @param nftId Id of the NFT which user wants to stake
     */
    function stake(
        address nftAddress,
        uint256 nftId
    ) external nonReentrant returns (bool) {
        require(allowNftAddress[nftAddress], "nft not allowed");
        require(!isPause, "staking is paused");
        require(
            IERC721(nftAddress).ownerOf(nftId) == msg.sender,
            "sender is not owner of nft"
        );

        // Transfer the NFT from user to this contract
        IERC721(nftAddress).safeTransferFrom(msg.sender, address(this), nftId);

        // Updating the UserInfo struct of the user
        UserInfo memory userInfo = UserInfo(msg.sender, block.number, 0, 0);
        userData[nftAddress][nftId] = userInfo;

        emit Staked(nftAddress, nftId);
        return true;
    }

    /**
     * @dev Unstake NFT of user, unbond for 1 day period and calculates the rewards of user in ERC20 token
     * @param nftAddress Address of NFT which user wants to unstake
     * @param nftId Id of the NFT which user wants to unstake
     */
    function unstake(address nftAddress, uint256 nftId) external nonReentrant {
        // getting UserInfo struct of user
        UserInfo memory _userInfo = userData[nftAddress][nftId];

        require(_userInfo.user == msg.sender, "sender is not owner of nft");
        require(_userInfo.unstakeAtBlock == 0, "already unstaked");

        // Calculation of rewards of user

        uint256 rewardIndex;

        uint256 len = blockNumbers.length;
        for (uint i; i < len; i++) {
            console.log("block number", blockNumbers[i]);
            console.log("user block", _userInfo.stakeAtBlock);
            if (_userInfo.stakeAtBlock < blockNumbers[i]) {
                rewardIndex = i;
                break;
            }
        }

        uint256 totalReward;
        // user=> block.number array[0] = 1
        // 10 block => update reward to 500 array[0,1] = 1,11
        // 20 block => user unstake = 21
        for (uint j = rewardIndex; j < len; j++) {
            if (j == rewardIndex) {
                totalReward +=
                    (blockNumbers[j] - _userInfo.stakeAtBlock) *
                    updatedRewards[blockNumbers[j - 1]];
                console.log("first", totalReward);
            } else if (j == (len - 1)) {
                totalReward +=
                    (block.number - blockNumbers[j]) *
                    updatedRewards[blockNumbers[j]];
                console.log("second", totalReward);
            } else {
                totalReward +=
                    (blockNumbers[j] - blockNumbers[j - 1]) *
                    updatedRewards[blockNumbers[j - 1]];
                console.log("third", totalReward);
            }
        }

        uint256 blockPerDay = 7200;
        uint256 rewardPerDay = 7200 * rewardPerBlock;
        uint256 rewardOfUser = totalReward + rewardPerDay;

        // Updating the UserInfo struct of the user
        _userInfo.rewardDebt = rewardOfUser;
        _userInfo.stakeAtBlock = 0;
        _userInfo.unstakeAtBlock = block.number;
        userData[nftAddress][nftId] = _userInfo;

        emit Unstaked(nftAddress, nftId);
    }

    /**
     * @dev Tranfer the NFT and rewards to the user after unbonding period who unstake NFT
     * @param nftAddress Address of NFT which user wants to claim rewards
     * @param nftId Id of the NFT which user wants to claim rewards
     */
    function claimRewards(
        address nftAddress,
        uint256 nftId
    ) external nonReentrant {
        // getting UserInfo struct of user
        UserInfo memory _userInfo = userData[nftAddress][nftId];

        require(_userInfo.rewardDebt != 0, "already claimRewards");
        require(_userInfo.user == msg.sender, "sender is not owner of nft");
        require(
            _userInfo.unstakeAtBlock + 7200 < block.number,
            "unbonding period"
        );

        // Mint ERC20 token to the user equivalent to his rewardDebt
        uint256 rewardOfUser = _userInfo.rewardDebt;
        _mint(msg.sender, rewardOfUser);

        // Trandfer the NFT to user form this address
        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);

        // Updating the UserInfo struct of the user
        _userInfo.rewardDebt = 0;
        _userInfo.stakeAtBlock = 0;
        _userInfo.unstakeAtBlock = 0;
        userData[nftAddress][nftId] = _userInfo;

        emit ClaimedRewards(nftAddress, nftId);
    }

    /**
     * @dev Allow and disallow the NFT to stake in protocol by owner
     * @param nftAddress Address of NFT which owner wants to allow
     * @param allowed boolean for allow and disallow the NFT address
     */
    function allowNft(address nftAddress, bool allowed) external onlyOwner {
        allowNftAddress[nftAddress] = allowed;
    }

    /**
     * @dev Pause or unpause the staking of NFT by owner
     * @param _isPause boolean to pause or unpause staking
     */
    function pauseStaking(bool _isPause) external onlyOwner {
        isPause = _isPause;
    }

    /**
     * @dev Change the rewards of staking NFT by owner
     * @param _newRewardPerBlock number of reward per block for staking NFT
     */
    function updateRewards(uint256 _newRewardPerBlock) external onlyOwner {
        blockNumbers.push(block.number);
        updatedRewards[block.number] = _newRewardPerBlock;
        rewardPerBlock = _newRewardPerBlock;
    }

    /**
     * @dev Allow and disallow the NFT to stake in protocol by owner
     * @param nftAddress Address of NFT which user wants to get data
     * @param nftId Id of NFT which user wants to get data
     */
    function getUserData(
        address nftAddress,
        uint256 nftId
    )
        external
        returns (
            address user,
            uint256 stakeAtBlock,
            uint256 rewardDebt,
            uint256 unstakeAtBlock
        )
    {
        UserInfo storage _userInfo = userData[nftAddress][nftId];
        return (
            _userInfo.user,
            _userInfo.stakeAtBlock,
            _userInfo.rewardDebt,
            _userInfo.unstakeAtBlock
        );
    }

    /**
     * @dev To implement the new implementation
     * @param newImplementation address of new implementation
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
