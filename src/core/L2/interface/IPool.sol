// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



interface IPool {

    event depositETH(uint chainId, address indexed from, address indexed to, uint256 value);

    event Withdraw32ETHtoCoustomerBridge(uint chainId, uint timestamp, address to, uint256 value);

    event CanWithdraw32ETH();


    error ChainIdNotSupported(uint chainId);

    error NotEnoughETH();

    error ChainIdIsNotSupported(uint id);

    error LessthanMINDepositAmount(uint MINDepositAmount,uint value);

    function deposit(uint chainId, address to) external payable returns(bool);
//TODO
//    function depositWETH(uint chainId, address to, uint256 value) external returns(bool);
}
