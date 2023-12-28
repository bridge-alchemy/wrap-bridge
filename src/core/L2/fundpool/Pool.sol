// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../../interfaces/IScrollCustomerBridge.sol";
import "../../../interfaces/IPolygonZkEVMCustomerBridge.sol";
import "../../../interfaces/IOptimismCustomerBridge.sol";
import "../../../interfaces/WETH.sol";
import "../../../interfaces/IL2Pool.sol";
import "../../libraries/ContractsAddress.sol";

contract L2Pool is
    IL2Pool,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;
    mapping(uint256 => bool) private IsSupportedChainId;
    mapping(address => bool) private IsSupportedStableCoin;
    uint256 public MINDepositAmount = 1e16;
    uint256 public perfee = 1_000; // 0.1%
    uint256 public Total_ETH_value;
    uint256 public Total_ETH_fee;
    uint256 public Total_ETH_StableCoin;
    uint256 public Total_ETH_StableCoin_fee;
    uint32 public constant MAX_GAS_Limit = 100_000; // 0.1%

    bytes32 public constant PAUSE_ROLE =
        keccak256(abi.encode(uint256(keccak256("PAUSE_ROLE")) - 1)) &
            ~bytes32(uint256(0xff));
    bytes32 public constant MINDepositAmount_ROLE =
        keccak256(abi.encode(uint256(keccak256("MINDepositAmount_ROLE")) - 1)) &
            ~bytes32(uint256(0xff));
    bytes32 public constant WithdrawToBridge_Role =
        keccak256(abi.encode(uint256(keccak256("WithdrawToBridge_Role")) - 1)) &
            ~bytes32(uint256(0xff));

    constructor() {
        _disableInitializers();
    }

    receive() external payable {}

    function initialize(address _MultisigWallet) public initializer {
        __AccessControl_init();
        __Pausable_init();
        grantRole(DEFAULT_ADMIN_ROLE, _MultisigWallet);
    }

    function depositETH(
        uint256 chainId,
        address to
    ) external payable override returns (bool) {
        if (!IsSupportChainId(chainId)) {
            revert ChainIdIsNotSupported(chainId);
        }
        if (msg.value < MINDepositAmount) {
            revert LessThanMINDepositAmount(MINDepositAmount, msg.value);
        }
        Total_ETH_value += msg.value;

        uint256 fee = (msg.value * perfee) / 1_000_000;
        uint256 amount = msg.value - fee;
        Total_ETH_fee += fee;
        emit DepositETH(chainId, msg.sender, to, amount);
        return true;
    }

    function depositWETH(
        uint256 chainId,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (!IsSupportChainId(chainId)) {
            revert ChainIdNotSupported(chainId);
        }

        uint256 Blockchain = block.chainid;
        IWETH WETH;
        if (Blockchain == 0x82750) {
            //https://chainlist.org/chain/534352
            //Scroll
            WETH = IWETH(ContractsAddress.ScrollWETH);
        } else if (Blockchain == 0x44d) {
            //https://chainlist.org/chain/1101
            //Polygon zkEVM
            WETH = IWETH(ContractsAddress.PolygonWETH);
        } else if (Blockchain == 0xa) {
            //https://chainlist.org/chain/10
            //OP Mainnet
            WETH = IWETH(ContractsAddress.OptimismWETH);
        } else if (Blockchain == 0xa4b1) {
            //https://chainlist.org/chain/42161
            //Arbitrum
            WETH = IWETH(ContractsAddress.ArbitrumWETH);
        } else if (Blockchain == 0xe708) {
            //https://chainlist.org/chain/59144
            //Linea
            WETH = IWETH(ContractsAddress.LineaWETH);
        } else {
            revert ErrorBlockChain();
        }

        uint256 BalanceBefore = WETH.balanceOf(address(this));
        WETH.transferFrom(msg.sender, address(this), value);
        uint256 BalanceAfter = WETH.balanceOf(address(this));
        uint256 amount = BalanceAfter - BalanceBefore;
        if (amount < MINDepositAmount) {
            revert LessThanMINDepositAmount(MINDepositAmount, amount);
        }
        WETH.withdraw(BalanceAfter);
        Total_ETH_value += amount;
        uint256 fee = (amount * perfee) / 1_000_000;
        amount -= fee;
        Total_ETH_fee += fee;
        emit DepositWETH(chainId, msg.sender, to, amount);

        return true;
    }

    function depositStableERC20(
        uint256 chainId,
        address to,
        address ERC20Address,
        uint256 value
    ) external override returns (bool) {
        if (!IsSupportChainId(chainId)) {
            revert ChainIdNotSupported(chainId);
        }
        if (!IsSupportStableCoin(ERC20Address)) {
            revert StableCoinNotSupported(ERC20Address);
        }

        uint256 BalanceBefore = IERC20(ERC20Address).balanceOf(address(this));
        IERC20(ERC20Address).safeTransferFrom(msg.sender, address(this), value);
        uint256 BalanceAfter = IERC20(ERC20Address).balanceOf(address(this));
        uint256 amount = BalanceAfter - BalanceBefore;
        Total_ETH_StableCoin += amount;
        uint256 fee = (amount * perfee) / 1_000_000;
        amount -= fee;
        Total_ETH_StableCoin_fee += fee;

        emit DepositERC20(chainId, ERC20Address, msg.sender, to, amount);

        return true;
    }

    //    function WithdrawStableCoinToOfficialBridge(
    //        address to
    //    ) external payable onlyRole(WithdrawToBridge_Role) returns (bool) {
    //        //TODO
    //        return true;
    //    }

    function IsSupportChainId(uint256 chainId) public view returns (bool) {
        return IsSupportedChainId[chainId];
    }

    function IsSupportStableCoin(
        address ERC20Address
    ) public view returns (bool) {
        return IsSupportedStableCoin[ERC20Address];
    }

    /* admin functions */

    function WithdrawETHtoOfficialBridge(
        address to
    ) external payable onlyRole(WithdrawToBridge_Role) returns (bool) {
        uint256 Blockchain = block.chainid;
        uint256 balance = address(this).balance;

        if (Blockchain == 0x82750) {
            //https://chainlist.org/chain/534352
            //Scroll
            IScrollCustomerL2Bridge(ContractsAddress.ScrollL2CustomerBridge)
                .withdrawETH{value: balance}(
                to,
                balance,
                uint256(MAX_GAS_Limit)
            );
        } else if (Blockchain == 0x44d) {
            //https://chainlist.org/chain/1101
            //Polygon zkEVM
            IPolygonZkEVML2CustomerBridge(
                ContractsAddress.PolygonL2CustomerBridge
            ).bridgeAsset{value: balance}(
                0,
                to,
                balance,
                address(0),
                false,
                ""
            );
        } else if (Blockchain == 0xa) {
            //https://chainlist.org/chain/10
            //OP Mainnet
            IOptimismL2CustomerBridge(ContractsAddress.OptimismL2CustomerBridge)
                .withdrawTo{value: balance}(
                ContractsAddress.OP_LEGACY_ERC20_ETH,
                to,
                balance,
                MAX_GAS_Limit,
                ""
            );
        } else if (Blockchain == 0xa4b1) {
            //https://chainlist.org/chain/42161
            //Arbitrum
            //TODO
        } else if (Blockchain == 0xe708) {
            //https://chainlist.org/chain/59144
            //Linea
            //TODO
        } else {
            revert ErrorBlockChain();
        }

        Total_ETH_fee = 0;

        emit WithdrawETHtoOfficialBridgeSuccess(
            block.chainid,
            block.timestamp,
            to,
            balance,
            Total_ETH_fee
        );
        return true;
    }

    function setValidChainId(
        uint256 chainId,
        bool isValid
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IsSupportedChainId[chainId] = isValid;
    }

    function setSupportStableCoin(
        address ERC20Address,
        bool isValid
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IsSupportedStableCoin[ERC20Address] = isValid;
    }

    function setPerfee(uint256 _perfee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        perfee = _perfee;
    }

    function pause() external onlyRole(PAUSE_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSE_ROLE) {
        _unpause();
    }

    function setMINDepositAmount(
        uint256 _MINDepositAmount
    ) external onlyRole(MINDepositAmount_ROLE) {
        MINDepositAmount = _MINDepositAmount;
    }
}
