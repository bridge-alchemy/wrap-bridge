// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "src/testnet/L1/fundpool/Pool.sol";
import "src/testnet/L1/Proxy.sol";
import "src/testnet/L1/ProxyTimeLockController.sol";


contract l1PoolDeployer is Script {
    address admin;
    address Bridge_ADMIN_ROLE;
    address CompletePools_ROLE;
    Proxy proxy;
    ProxyTimeLockController proxyTimeLockController;
    L1Pool l1Pool;
    address USDT = 0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC;
    function setUp() public {
        admin = 0xb6b5b53Dc43D5d84aa49F058517E3A04574a2c4F;
        Bridge_ADMIN_ROLE = 0xb6b5b53Dc43D5d84aa49F058517E3A04574a2c4F;
        CompletePools_ROLE = 0xb6b5b53Dc43D5d84aa49F058517E3A04574a2c4F;
    }


    function run() external {
        vm.startBroadcast();
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;

        l1Pool = new L1Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));
        proxy = new Proxy(address(l1Pool), address(proxyTimeLockController), _data);

        L1Pool(address(proxy)).grantRole(l1Pool.Bridge_ADMIN_ROLE(), Bridge_ADMIN_ROLE);
        L1Pool(address(proxy)).grantRole(l1Pool.CompletePools_ROLE(), CompletePools_ROLE);
        uint32 startTime = uint32(block.timestamp - block.timestamp % 86400 + 86400); // tomorrow
        L1Pool(address(proxy)).SetSupportToken(l1Pool.ETHAddress(), true, startTime);
        L1Pool(address(proxy)).SetSupportToken(l1Pool.WETHAddress(), true, startTime);
        L1Pool(address(proxy)).SetSupportToken(USDT, true, startTime);

        vm.stopBroadcast();
    }
}
