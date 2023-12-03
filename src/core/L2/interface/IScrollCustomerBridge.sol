// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


//Scroll 0x6EA73e05AdC79974B931123675ea8F78FfdacDF0
interface IScrollCustomerBridge {
    function withdrawETH(
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;
}
