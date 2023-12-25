pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "src/testnet/L2/fundpool/Pool.sol";
import "src/testnet/L2/Proxy.sol";
import "src/testnet/L2/ProxyTimeLockController.sol";


contract L2fundpoolTest is Test {

    address admin;
    ProxyTimeLockController proxyTimeLockController;
    Proxy proxy;
    L2Pool l2Pool;

    function setUp() public {
        admin = makeAddr("admin");

        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;


        l2Pool = new L2Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));
        proxy = new Proxy(address(l2Pool), address(proxyTimeLockController), _data);




    }

    function test_Deposit() public {
        console.log(block.chainid);
    }
}
