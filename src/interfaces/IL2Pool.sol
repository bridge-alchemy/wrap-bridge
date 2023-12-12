// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;



interface IL2Pool {

    event DepositETH(uint chainId, address indexed from, address indexed to, uint256 value);

    event DepositWETH(uint chainId, address indexed from, address indexed to, uint256 value);

    event WithdrawETHtoOfficialBridgeSuccess(uint chainId, uint timestamp, address to, uint256 value, uint256 accumulationfee);

    event DepositERC20(uint chainId,address indexed ERC20Address, address indexed from, address indexed to,  uint256 value);

    error ChainIdNotSupported(uint chainId);

    error StableCoinNotSupported(address ERC20Address);

    error NotEnoughETH();

    error ChainIdIsNotSupported(uint id);

    error ErrorBlockChain();

    error LessThanMINDepositAmount(uint MINDepositAmount,uint value);

    function depositETH(uint chainId, address to) external payable returns(bool);

    function depositWETH(uint chainId, address to, uint256 value) external returns(bool);

    function depositStableERC20(uint chainId, address to, address ERC20Address, uint256 value)  external returns(bool);

    function WithdrawETHtoOfficialBridgeSuccess(address to) external payable returns(bool);




}
