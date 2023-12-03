// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;


import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import "../interface/IScrollCustomerBridge.sol";
import "../interface/IPool.sol";


contract Pool is IPool, AccessControlUpgradeable,PausableUpgradeable{

    mapping(uint chainId => bool) private IsSupportedChainId;
    uint public MINDepositAmount = 1e16;
    uint public perfee = 1_000; // 0.1%
    uint public Total_value;
    bytes32 public constant PAUSE_ROLE = keccak256(abi.encode(uint256(keccak256("PAUSE_ROLE")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 public constant DepositAmount_ROLE = keccak256(abi.encode(uint256(keccak256("DepositAmount_ROLE")) - 1)) & ~bytes32(uint256(0xff));



    constructor(){
        _disableInitializers();
    }

    function initialize(address MultisigWallet) public initializer {
        __AccessControl_init();
        __Pausable_init();
        grantRole(DEFAULT_ADMIN_ROLE, MultisigWallet);
    }

    function deposit(uint chainId, address to) external  payable override returns(bool){
        if(!IsSupportChainId(chainId)) {
            revert ChainIdIsNotSupported(chainId);
        }
        if(msg.value < MINDepositAmount){
            revert LessthanMINDepositAmount(MINDepositAmount,msg.value);
        }
        Total_value += msg.value;
        if(Total_value > 32 ether){
            emit CanWithdraw32ETH();
        }
        uint fee = msg.value * perfee / 1_000_000;
        uint amount = msg.value - fee;
        emit  depositETH(chainId,msg.sender, to, amount);
        return true;
    }

//    function depositWETH(uint chainId, address to, uint256 value)  external returns(bool){
//        if(!IsSupportChainId(chainId)) {
//            revert ChainIdNotSupported(chainId);
//        }
//        WETH.transferFrom(msg.senfer,value);
//
//
//
//        return true;
//    }

    function IsSupportChainId(uint chainId) public view returns(bool){
        return IsSupportedChainId[chainId];
    }

    /* admin functions */
    //TODO

    function Deposit32ETHtoCoustomerBridge(address to) onlyRole(DEFAULT_ADMIN_ROLE) external payable returns(bool){
        if(Total_value < 32 ether){
            revert NotEnoughETH();
        }
        Total_value -= 32 ether;
        IScrollCustomerBridge(address(0x6EA73e05AdC79974B931123675ea8F78FfdacDF0)).withdrawETH(to,32 ether,0);
        emit Withdraw32ETHtoCoustomerBridge(block.chainid,  block.timestamp, to, 32 ether);
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

    function setMINDepositAmount(uint _MINDepositAmount) external onlyRole(DepositAmount_ROLE) {
        MINDepositAmount =  _MINDepositAmount;
    }


}
