// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//https://zkevm.polygonscan.com/address/0x5ac4182a1dd41aeef465e40b82fd326bf66ab82c#code#L1991
interface IPolygonZkEVMCustomerBridge {
    function bridgeAsset(
        uint32 destinationNetwork,
        address destinationAddress,
        uint256 amount,
        address token,
        bool forceUpdateGlobalExitRoot,
        bytes calldata permitData
    ) external payable;
}
