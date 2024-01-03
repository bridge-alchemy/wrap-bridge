// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../../interfaces/IL1Pool.sol";
import "../../../interfaces/WETH.sol";
import "../../../interfaces/IScrollCustomerBridge.sol";
import "../../../interfaces/IPolygonZkEVMCustomerBridge.sol";
import "../../../interfaces/IOptimismCustomerBridge.sol";
import "../../../interfaces/IArbitrumCustomerBridge.sol";
import "../../libraries/ContractsAddress.sol";
import "../../../interfaces/IL1MessageQueue.sol";
import "forge-std/Test.sol";

contract L1Pool is
    IL1Pool,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    address public constant ETHAddress =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
//    address public constant WETHAddress =
//        address(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f); // localTestMockWETH
        address public constant WETHAddress =
        address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    bytes32 public constant CompletePools_ROLE =
        keccak256(abi.encode(uint256(keccak256("CompletePools_ROLE")) - 1)) &
            ~bytes32(uint256(0xff));
    bytes32 public constant Bridge_ADMIN_ROLE =
        keccak256(abi.encode(uint256(keccak256("Bridge_ADMIN_ROLE")) - 1)) &
            ~bytes32(uint256(0xff));
    uint32 public periodTime;

    mapping(address => bool) public IsSupportToken;
    mapping(address => Pool[]) public Pools;
    mapping(address => User[]) public Users;
    mapping(address => uint256) public MinStakeAmount;
    address[] public SupportTokens;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _MultisigWallet) public initializer {
        __AccessControl_init();
        __Pausable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _MultisigWallet);
        periodTime = 3 days;
    }

    /*************************
     ***** User function *****
     *************************/

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
        uint256 PoolIndex = Pools[_token].length - 1;
        if (Pools[_token][PoolIndex].startTimestamp > block.timestamp) {
            Users[msg.sender].push(
                User({
                    isClaimed: false,
                    StartPoolId: PoolIndex,
                    EndPoolId: 0,
                    token: _token,
                    Amount: _amount
                })
            );
            Pools[_token][PoolIndex].TotalAmount += _amount;
        } else {
            revert NewPoolIsNotCreate(PoolIndex);
        }

        emit StarkingERC20Event(msg.sender, _token, _amount);
    }

    function StakingETH() external payable override nonReentrant whenNotPaused {
        if (msg.value < MinStakeAmount[address(ETHAddress)]) {
            revert LessThanMinStakeAmount(
                MinStakeAmount[address(ETHAddress)],
                msg.value
            );
        }
        if (Pools[address(ETHAddress)].length == 0) {
            revert NewPoolIsNotCreate(1);
        }
        uint256 PoolIndex = Pools[address(ETHAddress)].length - 1;
        if (
            Pools[address(ETHAddress)][PoolIndex].startTimestamp >
            block.timestamp
        ) {
            Users[msg.sender].push(
                User({
                    isClaimed: false,
                    StartPoolId: PoolIndex,
                    EndPoolId: 0,
                    token: ETHAddress,
                    Amount: msg.value
                })
            );
            Pools[address(ETHAddress)][PoolIndex].TotalAmount += msg.value;
        } else {
            revert NewPoolIsNotCreate(PoolIndex + 1);
        }

        emit StakingETHEvent(msg.sender, msg.value);
    }

    function StakingWETH(
        uint256 amount
    ) external override nonReentrant whenNotPaused {
        if (amount < MinStakeAmount[address(WETHAddress)]) {
            revert LessThanMinStakeAmount(MinStakeAmount[address(0)], amount);
        }

        IWETH(WETHAddress).transferFrom(msg.sender, address(this), amount);

        uint256 PoolIndex = Pools[address(WETHAddress)].length - 1;
        if (Pools[address(WETHAddress)][PoolIndex].IsCompleted) {
            revert PoolIsCompleted(PoolIndex);
        }
        if (
            Pools[address(WETHAddress)][PoolIndex].startTimestamp >
            block.timestamp
        ) {
            Users[msg.sender].push(
                User({
                    isClaimed: false,
                    StartPoolId: PoolIndex,
                    EndPoolId: 0,
                    token: WETHAddress,
                    Amount: amount
                })
            );
            Pools[address(WETHAddress)][PoolIndex].TotalAmount += amount;
        } else {
            revert NewPoolIsNotCreate(PoolIndex);
        }

        emit StakingWETHEvent(msg.sender, amount);
    }

    function ClaimAll() external override nonReentrant whenNotPaused {
        for (uint256 i = 0; i < SupportTokens.length; i++) {
            ClaimSimpleAsset(SupportTokens[i]);
        }
    }

    function ClaimSimpleAsset(
        address _token
    ) public override nonReentrant whenNotPaused {
        if (!IsSupportToken[_token]) {
            revert TokenIsNotSupported(_token);
        }
        if (Pools[_token].length == 0) {
            revert NewPoolIsNotCreate(0);
        }
        for (uint256 i = 0; i < Users[msg.sender].length; i++) {
            if (Users[msg.sender].length == 0) {
                break;
            }
            if (Users[msg.sender][i].token != _token) {
                continue;
            }
            if (Users[msg.sender][i].isClaimed) {
                continue;
            } //Last Completed PoolIndex
            uint256 EndPoolId = Pools[_token].length - 1;
            Pools[_token][EndPoolId].TotalAmount -= Users[msg.sender][i].Amount;

            uint256 Reward = 0;
            uint256 Amount = Users[msg.sender][i].Amount;
            uint256 startPoolId = Users[msg.sender][i].StartPoolId;
            if (startPoolId > EndPoolId) {
                revert NoReward();
            }

            for (uint256 j = startPoolId; j < EndPoolId; j++) {
                if (j > Pools[_token].length - 1) {
                    revert NewPoolIsNotCreate(j);
                }
                uint256 _Reward = (Amount * Pools[_token][j].TotalFee) /
                    Pools[_token][j].TotalAmount;
                Reward += _Reward;
                Pools[_token][j].TotalFeeClaimed += _Reward;
            }
            require(Reward > 0, "No Reward");
            Amount += Reward;
            Users[msg.sender][i].isClaimed = true;

            if (_token == address(ETHAddress)) {
                payable(msg.sender).transfer(Amount);
            } else if (_token == address(WETHAddress)) {
                IWETH(WETHAddress).transfer(msg.sender, Amount);
            } else {
                IERC20(_token).safeTransfer(msg.sender, Amount);
            }

            emit ClaimEvent(msg.sender, startPoolId, EndPoolId, _token, Amount);
            if (Users[msg.sender].length > 1) {
                Users[msg.sender][i] = Users[msg.sender][
                    Users[msg.sender].length - 1
                ];
            }
        }
    }

    /***************************************
     ***** CompletePools_ROLE function *****
     ***************************************/

    function CompletePoolAndNew(
        Pool[] memory CompletePools
    ) external payable onlyRole(CompletePools_ROLE) {
        for (uint256 i = 0; i < CompletePools.length; i++) {
            address _token = CompletePools[i].token;
            uint PoolIndex = Pools[_token].length - 1;
            Pools[_token][PoolIndex].IsCompleted = true;
            Pools[_token][PoolIndex].TotalFee = CompletePools[i].TotalFee;
            uint32 startTimes = Pools[_token][PoolIndex].endTimestamp;
            Pools[_token].push(
                Pool({
                    startTimestamp: startTimes,
                    endTimestamp: startTimes + periodTime,
                    token: _token,
                    TotalAmount: Pools[_token][PoolIndex].TotalAmount,
                    TotalFee: 0,
                    TotalFeeClaimed: 0,
                    IsCompleted: false
                })
            );
            emit CompletePoolEvent(_token, PoolIndex);
        }
    }

    function TransferAssertToBridge(
        uint256 Blockchain,
        address token,
        address to,
        uint256 amount
    ) external onlyRole(Bridge_ADMIN_ROLE) {
        if (Blockchain == 534351) {
            //https://chainlist.org/chain/534351
            //Scroll testnet
            uint fee = IL1MessageQueue(ContractsAddress.ScrollL1MessageQueue)
                .estimateCrossDomainMessageFee(30000);
            TransferAssertToScrollBridge(token, to, amount, fee);
        } else if (Blockchain == 1442) {
            //            https://chainlist.org/chain/1442
            //            Polygon zkEVM testnet
            TransferAssertToPolygonZkEvmBridge(token, to, amount);
        } else if (Blockchain == 11155420) {
            //https://chainlist.org/chain/11155420
            //OP Mainnet testnet
            TransferAssertToOptimismBridge(token, to, amount);
            //        } else if (Blockchain == 0xa4b1) {
            //            //https://chainlist.org/chain/42161
            //            //Arbitrum
            //            //Todo
            //            //            TransferAssertToArbitrumBridge(_token, to, _amount);
            //        } else if (Blockchain == 0xe708) {
            //            //https://chainlist.org/chain/59144
            //            //Linea
            //            //Todo
            //            //            TransferAssertToLineaBridge(_token, to, _amount);
        } else {
            revert ErrorBlockChain();
        }
    }

    function TransferAssertToScrollBridge(
        address _token,
        address to,
        uint256 _amount,
        uint256 fee
    ) internal {
        if (_token == address(ETHAddress)) {
            IScrollCustomerL1ETHBridge(
                ContractsAddress.ScrollL1CustomerETHBridge
            ).depositETH{value: _amount + fee}(to, _amount, 30000);
        } else if (_token == address(WETHAddress)) {
            IERC20(_token).approve(
                ContractsAddress.ScrollL1CustomerWETHBridge,
                _amount
            );
            IScrollCustomerL1WETHBridge(
                ContractsAddress.ScrollL1CustomerWETHBridge
            ).depositERC20(_token, to, _amount, uint256(gasleft()));
        } else {
            IERC20(_token).approve(
                ContractsAddress.ScrollL1CustomerWETHBridge,
                _amount
            );
            IScrollCustomerL1ERC20Bridge(
                ContractsAddress.ScrollL1CustomerERC20Bridge
            ).depositERC20(_token, to, _amount, uint256(gasleft()));
        }
    }

    function TransferAssertToPolygonZkEvmBridge(
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (_token == address(ETHAddress)) {
            IPolygonZkEVML1CustomerBridge(
                ContractsAddress.PolygonL1CustomerBridge
            ).bridgeAsset{value: _amount}(0x1, _to, _amount, _token, false, "");
        } else {
            IERC20(_token).approve(
                ContractsAddress.PolygonL1CustomerBridge,
                _amount
            );
            IPolygonZkEVML1CustomerBridge(
                ContractsAddress.PolygonL1CustomerBridge
            ).bridgeAsset(0x1, _to, _amount, _token, false, "");
        }
    }

    function TransferAssertToOptimismBridge(
        address _token,
        address to,
        uint256 _amount
    ) internal {
        if (_token == address(ETHAddress)) {
            IOptimismL1Bridge(ContractsAddress.OptimismL1CustomerBridge)
                .depositETHTo{value: _amount, gas: 11022052500000}(
                to,
                uint32(300000),
                ""
            );
        } else {
            IERC20(_token).approve(
                ContractsAddress.OptimismL2CustomerBridge,
                _amount
            );
            IOptimismL1Bridge(ContractsAddress.OptimismL2CustomerBridge)
                .depositERC20To(
                    _token,
                    _token,
                    to,
                    _amount,
                    uint32(gasleft()),
                    ""
                );
        }
    }

    function TransferAssertToArbitrumBridge(
        uint256 chainID,
        address _token,
        address to,
        uint256 _amount
    ) internal {
        // Todo
    }

    function TransferAssertToLineaBridge(
        uint256 chainID,
        address _token,
        address to,
        uint256 _amount
    ) internal {
        // Todo
    }

    /***************************************
     ***** Admin function *****
     ***************************************/

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
                startTimestamp: uint32(startTimes) - periodTime,
                endTimestamp: startTimes,
                token: _token,
                TotalAmount: 0,
                TotalFee: 0,
                TotalFeeClaimed: 0,
                IsCompleted: false
            })
        );
        //genesis pool

        Pools[_token].push(
            Pool({
                startTimestamp: uint32(startTimes),
                endTimestamp: startTimes + periodTime,
                token: _token,
                TotalAmount: 0,
                TotalFee: 0,
                TotalFeeClaimed: 0,
                IsCompleted: false
            })
        );
        //Next pool
        SupportTokens.push(_token);
        emit SetSupportTokenEvent(_token, _isSupport);
    }

    function getPoolLength(address _token) external view returns (uint256) {
        return Pools[_token].length;
    }

    function getUserLength(address _user) external view returns (uint256) {
        return Users[_user].length;
    }

    function getPool(
        address _token,
        uint256 _index
    ) external view returns (Pool memory) {
        return Pools[_token][_index];
    }

    function getUser(
        address _user,
        uint256 _index
    ) external view returns (User memory) {
        return Users[_user][_index];
    }
}
