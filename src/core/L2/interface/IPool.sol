// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



interface IPool {

    event DepositETH(uint chainId, address indexed from, address indexed to, uint256 value);

    event DepositWETH(uint chainId, address indexed from, address indexed to, uint256 value);

    event Withdraw32ETHtoCoustomerBridge(uint chainId, uint timestamp, address to, uint256 value);

    event CanWithdraw32ETH();

    error ChainIdNotSupported(uint chainId);

    error NotEnoughETH();

    error ChainIdIsNotSupported(uint id);

    error ErrorBlockChain();

    error LessThanMINDepositAmount(uint MINDepositAmount,uint value);

    function deposit(uint chainId, address to) external payable returns(bool);

    function depositWETH(uint chainId, address to, uint256 value) external returns(bool);

    function deposit32ETHtoCoustomerBridge() external payable returns(bool);


}
