// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;


import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "../interface/IScrollCustomerBridge.sol";
import "../interface/IPolygonZkEVMCustomerBridge.sol";
import "../interface/IOptimismCustomerBridge.sol";
import "../interface/WETH.sol";
import "../interface/IPool.sol";
import "../libraries/ContractsAddress.sol";


contract Pool is IPool, AccessControlUpgradeable,PausableUpgradeable, ReentrancyGuardUpgradeable{

    mapping(uint chainId => bool) private IsSupportedChainId;
    uint public MINDepositAmount = 1e16;
    uint public perfee = 1_000; // 0.1%
    uint public Total_value;
    address public L1Bridge;
    uint public constant ETHER_32 = 32 ether;
    uint32 public constant MAX_GAS_Limit = 100_000; // 100%
    bytes32 public constant PAUSE_ROLE = keccak256(abi.encode(uint256(keccak256("PAUSE_ROLE")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant MINDepositAmount_ROLE = keccak256(abi.encode(uint256(keccak256("MINDepositAmount_ROLE")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant WithdrawToBridge_Role = keccak256(abi.encode(uint256(keccak256("WithdrawToBridge_Role")) - 1)) & ~bytes32(uint256(0xff));


    constructor(){
        _disableInitializers();
    }

    function initialize(address _MultisigWallet, address _L1Bridge) public initializer {
        __AccessControl_init();
        __Pausable_init();
        grantRole(DEFAULT_ADMIN_ROLE, _MultisigWallet);
        L1Bridge = _L1Bridge;

    }

    function deposit(uint chainId, address to) external  payable override returns(bool){
        if(!IsSupportChainId(chainId)) {
            revert ChainIdIsNotSupported(chainId);
        }
        if(msg.value < MINDepositAmount){
            revert LessThanMINDepositAmount(MINDepositAmount,msg.value);
        }
        Total_value += msg.value;

        if(address(this).balance > ETHER_32){
            emit CanWithdraw32ETH();
        }
        uint fee = msg.value * perfee / 1_000_000;
        uint amount = msg.value - fee;
        emit  DepositETH(chainId, msg.sender, to, amount);
        return true;
    }

    function depositWETH(uint chainId, address to, uint256 value)  external override returns(bool){
        if(!IsSupportChainId(chainId)) {
            revert ChainIdNotSupported(chainId);
        }

        uint Blockchain = block.chainid;
        IWETH WETH;
        if (Blockchain == 0x82750) {
            //https://chainlist.org/chain/534352
            //Scroll
            WETH  = IWETH(ContractsAddress.ScrollWETH);


        } else if(Blockchain == 0x44d){
            //https://chainlist.org/chain/1101
            //Polygon zkEVM
            WETH  = IWETH(ContractsAddress.PolygonWETH);


        } else if(Blockchain == 0xa){
            //https://chainlist.org/chain/10
            //OP Mainnet
            WETH  = IWETH(ContractsAddress.OptimismWETH);


        } else if(Blockchain == 0xa4b1){
            //https://chainlist.org/chain/42161
            //Arbitrum
            WETH  = IWETH(ContractsAddress.ArbitrumWETH);


        } else if(Blockchain == 0xe708){
            //https://chainlist.org/chain/59144
            //Linea
            WETH  = IWETH(ContractsAddress.LineaWETH);


        } else {
            revert ErrorBlockChain();
        }

        uint BalanceBefore = WETH.balanceOf(address(this));
        WETH.transferFrom(msg.sender, address(this), value);
        uint BalanceAfter = WETH.balanceOf(address(this));
        uint amount = BalanceAfter - BalanceBefore;
        if(amount < MINDepositAmount){
            revert LessThanMINDepositAmount(MINDepositAmount,amount);
        }
        WETH.withdraw(BalanceAfter);
        Total_value += amount;
        emit DepositWETH(chainId, msg.sender, to, amount);

        return true;
    }

    function IsSupportChainId(uint chainId) public view returns(bool){
        return IsSupportedChainId[chainId];
    }

    /* admin functions */


    function deposit32ETHtoCoustomerBridge() onlyRole(WithdrawToBridge_Role) external payable returns(bool){
        if(address(this).balance < ETHER_32){
            revert NotEnoughETH();
        }


        uint Blockchain = block.chainid;

        if (Blockchain == 0x82750) {
            //https://chainlist.org/chain/534352
            //Scroll
            IScrollCustomerBridge(ContractsAddress.ScrollCustomerBridge).withdrawETH{value: ETHER_32}(L1Bridge, ETHER_32, uint256(MAX_GAS_Limit));

        }else if(Blockchain == 0x44d){
            //https://chainlist.org/chain/1101
            //Polygon zkEVM
            IPolygonZkEVMCustomerBridge(ContractsAddress.PolygonCustomerBridge).bridgeAsset(0, L1Bridge, ETHER_32, address(0), false, "");



        }else if(Blockchain == 0xa){
            //https://chainlist.org/chain/10
            //OP Mainnet
            IOptimismCustomerBridge(ContractsAddress.OptimismCustomerBridge).withdrawTo(ContractsAddress.OP_LEGACY_ERC20_ETH, L1Bridge,  ETHER_32, MAX_GAS_Limit, "");


        }else if(Blockchain == 0xa4b1){
            //https://chainlist.org/chain/42161
            //Arbitrum
            //TODO

        }else if(Blockchain == 0xe708){
            //https://chainlist.org/chain/59144
            //Linea
            //TODO


        }else{
            revert ErrorBlockChain();
        }



        emit Withdraw32ETHtoCoustomerBridge(block.chainid,  block.timestamp, L1Bridge,  32 ether);
        return true;
    }

    function setValidChainId(uint chainId, bool isValid) onlyRole(DEFAULT_ADMIN_ROLE) external {
        IsSupportedChainId[chainId] = isValid;
    }


    function setPerfee(uint _perfee) onlyRole(DEFAULT_ADMIN_ROLE) external {
        perfee = _perfee;
    }


    function pause() external onlyRole(PAUSE_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSE_ROLE) {
        _unpause();
    }

    function setMINDepositAmount(uint _MINDepositAmount) external onlyRole(MINDepositAmount_ROLE) {
        MINDepositAmount =  _MINDepositAmount;
    }


}
