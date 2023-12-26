// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IL1MessageQueue {
    function estimateCrossDomainMessageFee(uint256 _gasLimit)
        external
        view
        returns (uint256);
}
