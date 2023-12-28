// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

interface IL2Pool {
    event DepositETH(
        uint256 chainId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event DepositWETH(
        uint256 chainId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event WithdrawETHtoOfficialBridgeSuccess(
        uint256 chainId,
        uint256 timestamp,
        address to,
        uint256 value,
        uint256 accumulationfee
    );

    event DepositERC20(
        uint256 chainId,
        address indexed ERC20Address,
        address indexed from,
        address indexed to,
        uint256 value
    );

    error ChainIdNotSupported(uint256 chainId);

    error StableCoinNotSupported(address ERC20Address);

    error NotEnoughETH();

    error ChainIdIsNotSupported(uint256 id);

    error ErrorBlockChain();

    error LessThanMINDepositAmount(uint256 MINDepositAmount, uint256 value);

    function depositETH(
        uint256 chainId,
        address to
    ) external payable returns (bool);

    function depositWETH(
        uint256 chainId,
        address to,
        uint256 value
    ) external returns (bool);

    function depositStableERC20(
        uint256 chainId,
        address to,
        address ERC20Address,
        uint256 value
    ) external returns (bool);

//    function WithdrawStableCoinToOfficialBridge(
//        address to
//    ) external payable returns (bool);
}
