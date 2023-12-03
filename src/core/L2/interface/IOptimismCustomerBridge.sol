// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



//OP 0x4200000000000000000000000000000000000010
interface IOptimismCustomerBridge {

    function withdrawTo(
        address _l2Token,
        address _to,
        uint256 _amount,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) external payable;
}
