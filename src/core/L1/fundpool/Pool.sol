// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../../interfaces/IL1Pool.sol";
import "../../../interfaces/WETH.sol";

contract L1Pool is
    IL1Pool,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;
    address public constant ETHAddress =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address public constant WETHAddress =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint public periodTime = 3 * 1 days;
    mapping(address => bool) public IsSupportToken;
    mapping(address => uint256) public balances;

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
        uint256 PoolId;
        uint256 Amount;
    }

    mapping(address => Pool[]) public Pools;
    mapping(address => User[]) public Users;
    mapping(address => uint256) public MinStakeAmount;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _MultisigWallet) public initializer {
        __AccessControl_init();
        __Pausable_init();
        grantRole(DEFAULT_ADMIN_ROLE, _MultisigWallet);
    }

    function StarkingERC20(
        address _token,
        uint256 _amount
    ) external override nonReentrant whenNotPaused {
        if (!IsSupportToken[_token]) {
            revert TokenIsNotSupported(_token);
        }
        if (_amount < MinStakeAmount[_token]) {
            revert LessThanMinStakeAmount(MinStakeAmount[_token], _amount);
        }

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        uint PoolIndex = Pools[_token].length - 1;
        if (Pools[_token][PoolIndex].startTimestamp > block.timestamp) {
            Users[msg.sender].push(
                User({
                    isClaimed: false,
                    PoolId: PoolIndex,
                    token: _token,
                    Amount: _amount
                })
            );
            Pools[_token][PoolIndex].TotalAmount += _amount;
        }

        emit StarkingERC20Event(msg.sender, _token, _amount);
    }

    function StakingETH() external payable override nonReentrant whenNotPaused {
        if (msg.value < MinStakeAmount[address(ETHAddress)]) {
            revert LessThanMinStakeAmount(
                MinStakeAmount[address(0)],
                msg.value
            );
        }
        uint PoolIndex = Pools[address(ETHAddress)].length - 1;
        if (
            Pools[address(ETHAddress)][PoolIndex].startTimestamp >
            block.timestamp
        ) {
            Users[msg.sender].push(
                User({
                    isClaimed: false,
                    PoolId: PoolIndex,
                    token: _token,
                    Amount: _amount
                })
            );
            Pools[address(ETHAddress)][PoolIndex].TotalAmount += msg.value;
        }

        emit StakingETHEvent(msg.sender, msg.value);
    }

    function StakingWETH(
        uint amount
    ) external override nonReentrant whenNotPaused {
        if (amount < MinStakeAmount[address(WETHAddress)]) {
            revert LessThanMinStakeAmount(MinStakeAmount[address(0)], amount);
        }

        WETH(WETHAddress).safeTransferFrom(msg.sender, address(this), amount);

        uint PoolIndex = Pools[address(WETHAddress)].length - 1;
        if (
            Pools[address(WETHAddress)][PoolIndex].startTimestamp >
            block.timestamp
        ) {
            Users[msg.sender].push(
                User({
                    isClaimed: false,
                    PoolId: PoolIndex,
                    token: _token,
                    Amount: _amount
                })
            );
            Pools[address(WETHAddress)][PoolIndex].TotalAmount += amount;
        }
        if (Pools[address(WETHAddress)][PoolIndex].isCompleted) {
            revert PoolIsCompleted(PoolIndex);
        }

        emit StakingWETHEvent(msg.sender, amount);
    }

    function Claim() external override nonReentrant whenNotPaused {
        for (uint256 i = 0; i < Users[msg.sender].length; i++) {
            uint256 PoolId = Users[msg.sender][i].PoolId;
            uint256 Amount = Users[msg.sender][i].Amount;
            address token = Users[msg.sender][i].token;
            if (Pools[token][PoolId].IsCompleted) {
                Users[msg.sender][i].isClaimed = true;
                if (token == address(ETHAddress)) {
                    payable(msg.sender).transfer(Amount);
                } else if (token == address(WETHAddress)) {
                    WETH(WETHAddress).transfer(Amount);
                } else {
                    IERC20(token).safeTransfer(msg.sender, Amount);
                }
                emit ClaimEvent(msg.sender, PoolId, token, Amount);
                Users[msg.sender][i] = Users[msg.sender][length - 1];
                Users[msg.sender].pop();
                i--;
            }
        }
    }

    function setMinStakeAmount(
        address _token,
        uint256 _amount
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_amount < 0) {
            revert LessThanZero(_amount);
        }
        MinStakeAmount[_token] = _amount;
        emit SetMinStakeAmountEvent(_token, _amount);
    }

    function SetSupportToken(
        address _token,
        bool _isSupport,
        uint32 startTimes
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (IsSupportToken[_token]) {
            revert TokenIsAlreadySupported(_token, _isSupport);
        }
        IsSupportToken[_token] = _isSupport;
        Pools[_token].push(
            Pool({
                startTimestamp: uint32(startTimes),
                endTimestamp: uint32(startTimes + periodTime),
                token: _token,
                TotalAmount: 0,
                TotalFee: 0,
                TotalFeeClaimed: 0,
                IsCompleted: false
            })
        );
        emit SetSupportTokenEvent(_token, _isSupport);
    }
}
