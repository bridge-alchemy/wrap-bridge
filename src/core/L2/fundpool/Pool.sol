// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interface/IPool.sol";
import "../interface/IScrollBridge.sol";
contract Pool is IPool {

    mapping(uint chainId => bool) private IsSupportedChainId;
    uint public constant  MINDepositAmount = 1e16;
    uint public perfee = 1_000; // 0.1%
    uint public Total_value;
//    mapping(address token=> bool) public IsSupportedERC20Token;

    /**
     * @dev Throws if called by any account other than the owner.
     */

    constructor(address MultiSigAddress){
        _setupRole(DEFAULT_ADMIN_ROLE, MultiSigAddress);
    }

    function deposit(uint chainId, address to) external  payable returns(bool){
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
        fee = msg.value * perfee / 1_000_000;
        amount = msg.value - fee;
        emit  depositETH(chainId,msg.sender, to, amount);
        return true;
    }

    function depositWETH(uint chainId, address to, uint256 value)  external returns(bool){
        if(!IsSupportChainId(chainId)) {
            revert ChainIdNotSupported(chainId);
        }
        WETH.transferFrom(msg.senfer,value);



        return true;
    }

    /* admin functions */

    function Deposit32ETHtoCoustomerBridge(address to) onlyRole(DEFAULT_ADMIN_ROLE) external payable returns(bool){
        if(Total_value < 32 ether){
            revert NotEnoughETH();
        }
        Total_value -= 32 ether;
        IScrollBridge(address(0x6EA73e05AdC79974B931123675ea8F78FfdacDF0)).withdrawETH(to,32 ether,0);
        emit Withdraw32ETHtoCoustomerBridge(to,32 ether);
        return true;
    }

    function setValidChainId(uint chainId, bool isValid) onlyRole(DEFAULT_ADMIN_ROLE) external {
        IsSupportedChainId[chainId] = isValid;
    }


}
