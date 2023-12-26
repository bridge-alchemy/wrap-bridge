// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IL1Pool {

    struct Pool {
        uint32 startTimestamp;
        uint32 endTimestamp;
        address token;
        uint256 TotalAmount;
        uint256 TotalFee;
        uint256 TotalFeeClaimed;
        bool IsCompleted;
    }

    struct User {
        bool isClaimed;
        address token;
        uint256 StartPoolId;
        uint256 EndPoolId;
        uint256 Amount;
    }
    function StarkingERC20(address _token, uint256 _amount) external;
    function StakingETH() external payable;
    function StakingWETH(uint256 amount) external;
    function ClaimAll() external;
    function ClaimSimpleAsset(address _token) external;
    function CompletePoolAndNew(Pool[] memory CompletePools)  external payable;
    function setMinStakeAmount(address _token, uint256 _amount) external;
    function SetSupportToken(address _token, bool _isSupport, uint32 startTimes) external;
    function TransferAssertToBridge(uint256 Blockchain,address _token, address _to, uint256 _amount) external;
    // 定义事件
    event StarkingERC20Event(address indexed user, address indexed token, uint256 amount);
    event StakingETHEvent(address indexed user, uint256 amount);
    event StakingWETHEvent(address indexed user, uint256 amount);
    event ClaimEvent(address indexed user, uint256 startPoolId, uint256 endPoolId, address indexed token, uint256 amount);
    event CompletePoolEvent(address indexed token, uint256 poolIndex);
    event SetMinStakeAmountEvent(address indexed token, uint256 amount);
    event SetSupportTokenEvent(address indexed token, bool isSupport);

    error NoReward();
    error ErrorBlockChain();
    error TokenIsNotSupported(address token);
    error NewPoolIsNotCreate(uint256 PoolIndex);
    error LessThanMinStakeAmount(uint256 minAmount, uint256 providedAmount);
    error PoolIsCompleted(uint256 poolIndex);
    error AlreadyClaimed();
    error LessThanZero(uint256 amount);
    error TokenIsAlreadySupported(address token, bool isSupported);
}
