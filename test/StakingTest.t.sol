// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Staking} from "../src/Staking.sol";
import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MockNft} from "../src/MockNft.sol";
import "forge-std/console.sol";

contract StakingTest is Test {
    Staking stakingImp;
    Staking stakingProxy;

    MockNft mockNft;
    MockNft mockNft2;

    address public user;
    address public user2;
    address public owner;
    address public implementation;
    bytes public data;

    address public nftAddress;
    uint256 public nftId;

    address public userA;
    address public userB;
    address public userC;

    function setUp() external {
        user = makeAddr("user");
        user2 = makeAddr("user2");

        userA = makeAddr("userA");
        userB = makeAddr("userB");
        userC = makeAddr("userC");

        owner = makeAddr("owner");
        implementation = makeAddr("implementation");
        data = hex"";

        mockNft = new MockNft();
        mockNft2 = new MockNft();

        mockNft.mint(user, 1);
        mockNft2.mint(user, 1);

        mockNft.mint(userA, 2);
        mockNft.mint(userA, 3);
        mockNft.mint(userB, 4);
        mockNft.mint(userC, 5);

        deployStaking();
    }

    function deployStaking() internal {
        vm.startPrank(owner);
        stakingImp = new Staking();
        data = abi.encodeCall(stakingImp.initialize, ());
        address staking = address(new ERC1967Proxy(address(stakingImp), data));
        stakingProxy = Staking(staking);
        vm.stopPrank();
    }

    function testRe() public {
        allowMockNft();
        uint256 day1 = block.number + 10;
        vm.roll(day1);
        vm.startPrank(userA);
        mockNft.approve(address(stakingProxy), 2);
        stakingProxy.stake(address(mockNft), 2);
        vm.stopPrank();

        vm.roll(day1 + 10);
        vm.prank(owner);
        stakingProxy.updateRewards(500);

        vm.roll(day1 + 20);
        vm.startPrank(userA);
        stakingProxy.unstake(address(mockNft), 2);
        vm.stopPrank();

        (, , uint256 rewardsForUserAForId2, ) = stakingProxy.getUserData(
            address(mockNft),
            2
        );
        console.log("userA rewards for nftId 2", rewardsForUserAForId2);
    }

    function testReawardsForUsers() public {
        allowMockNft();
        uint256 day1 = block.number;
        vm.roll(day1);
        vm.startPrank(userA);
        mockNft.approve(address(stakingProxy), 2);
        stakingProxy.stake(address(mockNft), 2);
        vm.stopPrank();

        uint256 day31 = block.number + (30 * 7200);
        vm.roll(day31);
        vm.startPrank(userB);
        mockNft.approve(address(stakingProxy), 4);
        stakingProxy.stake(address(mockNft), 4);
        vm.stopPrank();

        uint256 day61 = day31 + (30 * 7200);
        vm.roll(day61);
        vm.prank(owner);
        stakingProxy.updateRewards(600);

        vm.startPrank(userC);
        mockNft.approve(address(stakingProxy), 5);
        stakingProxy.stake(address(mockNft), 5);
        vm.stopPrank();

        uint256 day181 = day31 + (120 * 7200);
        vm.roll(day181);
        vm.prank(owner);
        stakingProxy.updateRewards(1200);

        vm.startPrank(userA);
        mockNft.approve(address(stakingProxy), 3);
        stakingProxy.stake(address(mockNft), 3);
        vm.stopPrank();

        uint256 day360 = day31 + (180 * 7200);
        vm.roll(day360);
        vm.startPrank(userA);
        stakingProxy.unstake(address(mockNft), 2);
        // stakingProxy.unstake(address(mockNft), 3);
        vm.stopPrank();

        (, , uint256 rewardsForUserAForId2, ) = stakingProxy.getUserData(
            address(mockNft),
            2
        );
        (, , uint256 rewardsForUserAForId3, ) = stakingProxy.getUserData(
            address(mockNft),
            3
        );
        console.log("userA rewards for nftId 2", rewardsForUserAForId2);
        console.log("userA rewards for nftId 3", rewardsForUserAForId3);
        console.log(
            "userA total Rewards",
            (rewardsForUserAForId2 + rewardsForUserAForId3)
        );
    }

    // Checking reward per block is 100 at start
    function testRewardPerBlockAtStart() public {
        assertEq(stakingProxy.rewardPerBlock(), 100);
    }

    // checking staking is not paused at start
    function testIsPauseAtStart() public {
        assertEq(stakingProxy.isPause(), false);
    }

    // Testing only owner can allow nft for staking
    function testAllowNft() public {
        vm.startPrank(owner);
        stakingProxy.allowNft(address(mockNft), true);
        assertEq(stakingProxy.allowNftAddress(address(mockNft)), true);
        stakingProxy.allowNft(address(mockNft), false);
        assertEq(stakingProxy.allowNftAddress(address(mockNft)), false);
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert();
        stakingProxy.allowNft(address(mockNft), true);
        vm.stopPrank();
    }

    // Testing owner can pasue and unpause staking anytime
    function testPauseStaking() public {
        vm.startPrank(owner);
        stakingProxy.pauseStaking(true);
        assertEq(stakingProxy.isPause(), true);
        stakingProxy.pauseStaking(false);
        assertEq(stakingProxy.isPause(), false);
        vm.stopPrank();
    }

    // Testing owner can update the rewards per block
    function testUpdateRewards() public {
        vm.startPrank(owner);
        stakingProxy.updateRewards(200);
        assertEq(stakingProxy.rewardPerBlock(), 200);
        vm.stopPrank();
    }

    // Testing user can stake NFT and UserInfo struct of that user sets at intended values
    function testStake() public {
        allowMockNft();
        vm.startPrank(user);
        mockNft.approve(address(stakingProxy), 1);
        bool result = stakingProxy.stake(address(mockNft), 1);
        vm.stopPrank();
        assert(mockNft.ownerOf(1) == address(stakingProxy));
        assertEq(result, true);

        (
            address userAddress,
            uint256 stakeAtBlock,
            uint256 rewardDebt,
            uint256 unstakeAtBlock
        ) = stakingProxy.getUserData(address(mockNft), 1);

        assertEq(userAddress, user);
        assertEq(stakeAtBlock, block.number);
        assertEq(rewardDebt, 0);
        assertEq(unstakeAtBlock, 0);
    }

    // Testing require statements of stake function
    function testStakeRquireStatements() public {
        allowMockNft();
        vm.startPrank(user);
        mockNft2.approve(address(stakingProxy), 1);
        vm.expectRevert();
        stakingProxy.stake(address(mockNft2), 1);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert();
        mockNft.approve(address(stakingProxy), 1);
        vm.expectRevert();
        stakingProxy.stake(address(mockNft), 1);
        vm.stopPrank();

        vm.startPrank(owner);
        stakingProxy.pauseStaking(true);
        vm.stopPrank();

        vm.startPrank(user);
        mockNft.approve(address(stakingProxy), 1);
        vm.expectRevert();
        stakingProxy.stake(address(mockNft), 1);
    }

    // Allowing mockNft for staking
    function allowMockNft() internal {
        vm.startPrank(owner);
        stakingProxy.allowNft(address(mockNft), true);
        vm.stopPrank();
    }

    // Testing that only user who stake his NFT can unstake NFT, UserInfo struct sets at intended values
    // also intended calculation of rewards and all the require statements of unstake function
    function testUnstake() public {
        allowMockNft();
        vm.startPrank(user);
        mockNft.approve(address(stakingProxy), 1);
        bool result = stakingProxy.stake(address(mockNft), 1);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert();
        stakingProxy.unstake(address(mockNft), 1);
        vm.stopPrank();

        vm.startPrank(user);
        vm.roll(block.number + 10);
        stakingProxy.unstake(address(mockNft), 1);
        vm.stopPrank();

        (
            address userAddress,
            uint256 stakeAtBlock,
            uint256 rewardDebt,
            uint256 unstakeAtBlock
        ) = stakingProxy.getUserData(address(mockNft), 1);

        assertEq(userAddress, user);
        assertEq(stakeAtBlock, 0);
        assertEq(rewardDebt, (720000 + 1000));
        assertEq(unstakeAtBlock, block.number);

        vm.startPrank(user);
        vm.expectRevert();
        stakingProxy.unstake(address(mockNft), 1);
        vm.stopPrank();
    }

    // Testing only user who unstake his NFT can withdraw NFT and claim rewards after a unbonding period
    // UserInfo struct sets at intended values and all require statements of claimReward function
    function testClaimRewards() public {
        allowMockNft();
        vm.startPrank(user);
        mockNft.approve(address(stakingProxy), 1);
        bool result = stakingProxy.stake(address(mockNft), 1);

        vm.roll(block.number + 10);
        stakingProxy.unstake(address(mockNft), 1);

        vm.expectRevert();
        stakingProxy.claimRewards(address(mockNft), 1);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert();
        stakingProxy.claimRewards(address(mockNft), 1);
        vm.stopPrank();

        vm.startPrank(user);
        vm.roll(block.number + 7201);
        stakingProxy.claimRewards(address(mockNft), 1);
        vm.stopPrank();

        assert(mockNft.ownerOf(1) == address(user));
        assertEq(stakingProxy.balanceOf(user), 720000 + 1000);

        (
            address userAddress,
            uint256 stakeAtBlock,
            uint256 rewardDebt,
            uint256 unstakeAtBlock
        ) = stakingProxy.getUserData(address(mockNft), 1);

        assertEq(userAddress, user);
        assertEq(stakeAtBlock, 0);
        assertEq(rewardDebt, 0);
        assertEq(unstakeAtBlock, 0);

        vm.startPrank(user);
        vm.expectRevert();
        stakingProxy.claimRewards(address(mockNft), 1);
        vm.stopPrank();
    }

    // Testing anyone cannot set new implementation
    function test_authorizeUpgrade() public {
        vm.expectRevert();
        stakingProxy.upgradeToAndCall(implementation, data);
    }
}
