// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract Proxy is TransparentUpgradeableProxy {
    constructor(
        address BridgeLogic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(BridgeLogic, admin_, _data) {}
}
