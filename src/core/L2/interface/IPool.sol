// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin/contracts/access/AccessControl.sol";

interface IPool is accessControl {

    event depositETH(uint chainId, address indexed from, address indexed to, uint256 value);


    event CanWithdraw32ETH();

    event depositETH(uint chainId, address indexed from, address indexed to, uint256 value);

    error ChainIdIsNotSupported(address sender);

    error LessthanMINDepositAmount(uint MINDepositAmount,uint value);

    function deposit(uint chainId, address to) external payable returns(bool);

    function depositWETH(uint chainId, address to, uint256 value) external returns(bool);
}
