// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract Staking is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 rewardPerBlock = 100;
    struct UserInfo {
        address user;
        uint256 stakeAtBlock;
        uint256 rewardDebt;
        uint256 unstakeAtBlock;
    }

    bool isPause;
    mapping(address nftAddress => mapping(uint256 nftId => UserInfo))
        public userData;
    mapping(address nftAddress => bool) public allowNftAddress;

    function initialize() public initializer {
        __ERC20_init("RewardToken", "RT");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }
    constructor() {
        _disableInitializers();
    }

    function stake(address nftAddress, uint256 nftId) external returns (bool) {
        require(allowNftAddress[nftAddress], "nft not allowed");
        require(!isPause, "staking is paused");
        require(nftAddress != address(0), "must not address(0)");
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender, "not owner");

        IERC721(nftAddress).transferFrom(msg.sender, address(this), nftId);

        UserInfo memory userInfo = UserInfo(msg.sender, block.number, 0, 0);

        userData[nftAddress][nftId] = userInfo;
        return true;
    }

    function unstake(address nftAddress, uint256 nftId) external {
        UserInfo memory _userInfo = userData[nftAddress][nftId];

        require(nftAddress != address(0), "must not address(0)");
        require(_userInfo.user == msg.sender, "sender is not owner of nft");
        require(_userInfo.unstakeAtBlock == 0, "already unstaked");

        uint256 blockPerDay = 7200;
        uint256 totalBlocksStaked = (block.number - _userInfo.stakeAtBlock);
        uint256 rewardOfUser = (totalBlocksStaked + blockPerDay) *
            rewardPerBlock;

        _userInfo.rewardDebt = rewardOfUser;
        _userInfo.stakeAtBlock = 0;
        _userInfo.unstakeAtBlock = block.number;

        userData[nftAddress][nftId] = _userInfo;
    }

    function claimRewards(address nftAddress, uint256 nftId) external {
        UserInfo memory _userInfo = userData[nftAddress][nftId];

        require(nftAddress != address(0), "must not address(0)");
        require(_userInfo.user == msg.sender, "sender is not owner of nft");
        require(
            _userInfo.unstakeAtBlock + 7200 > block.number,
            "unbonding period"
        );

        uint256 rewardOfUser = _userInfo.rewardDebt;
        _mint(msg.sender, rewardOfUser);
    }

    function allowNft(address nftAddress, bool allowed) external onlyOwner {
        allowNftAddress[nftAddress] = allowed;
    }

    function pauseStaking(bool _isPause) external onlyOwner {
        isPause = _isPause;
    }

    function updateRewards(uint256 _newRewardPerBlock) external onlyOwner {
        rewardPerBlock = _newRewardPerBlock;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
