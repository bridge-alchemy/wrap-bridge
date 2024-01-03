// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "src/testnet/L2/fundpool/Pool.sol";
import "src/testnet/L2/Proxy.sol";
import "src/testnet/L2/ProxyTimeLockController.sol";


contract L2PoolDeployer is Script {
    address admin;
    address WithdrawToBridge_Role;
    Proxy proxy;
    ProxyTimeLockController proxyTimeLockController;
    L2Pool l2Pool;
    function setUp() public {
        admin = 0xb6b5b53Dc43D5d84aa49F058517E3A04574a2c4F;
        WithdrawToBridge_Role = 0xb6b5b53Dc43D5d84aa49F058517E3A04574a2c4F;
    }

    function run() external {
        vm.startBroadcast();
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;

        l2Pool = new L2Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));
        proxy = new Proxy(address(l2Pool), address(proxyTimeLockController), _data);

        L2Pool(address(proxy)).grantRole(l2Pool.WithdrawToBridge_Role(), WithdrawToBridge_Role);
        L2Pool(address(proxy)).setValidChainId(11155111, true); // sepolia
        L2Pool(address(proxy)).setValidChainId(534351, true); // Scroll Sepolia
        L2Pool(address(proxy)).setValidChainId(11155420, true); // OP Sepolia
        vm.stopBroadcast();
    }
}
