// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// https://scrollscan.com/address/0xe0a0509a66c509f55c85a20eb8c60676135081f7#code#F8#L47
interface IScrollCustomerL2Bridge {
    function withdrawETH(
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;
}

interface IScrollCustomerL1ETHBridge {
    function depositETH(
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;

}

interface IScrollCustomerL1WETHBridge {
    function depositERC20(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;

}

interface IScrollCustomerL1ERC20Bridge {
    function depositERC20(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;

}
