pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "src/testnet/L1/fundpool/Pool.sol";
import "src/testnet/L1/Proxy.sol";
import "src/testnet/L1/ProxyTimeLockController.sol";


contract L1fundpoolTest is Test {

    address admin;
    ProxyTimeLockController proxyTimeLockController;
    Proxy proxy;
    L1Pool l1Pool;

    IWETH WETH = IWETH(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    address testUser = 0xc9f148da22aFB80dEc9BFD3679c60fABba9d360F;
    function setUp() public {
        admin = makeAddr("admin");

        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;


        l1Pool = new L1Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));
        proxy = new Proxy(address(l1Pool), address(proxyTimeLockController), _data);
        vm.startPrank(admin);


        L1Pool(address(proxy)).setMinStakeAmount(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), 0.1 ether);
//        L1Pool(address(proxy)).grantRole()
        L1Pool(address(proxy)).SetSupportToken(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), true, uint32(block.timestamp - block.timestamp % 86400));
        L1Pool(address(proxy)).SetSupportToken(address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9), true, uint32(block.timestamp - block.timestamp % 86400));
        L1Pool(address(proxy)).SetSupportToken(address(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC), true, uint32(block.timestamp - block.timestamp % 86400));
        vm.stopPrank();

    }


    function test_DepositETH() public {
       vm.prank(testUser);
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();

    }

    function test_DepositWETH() public {
        vm.startPrank(testUser);
        WETH.approve(address(proxy), 1 ether);
        L1Pool(address(proxy)).StakingWETH(1 ether);
        vm.stopPrank();
    }

    function test_DepositUSDT() public {
        vm.startPrank(testUser);
        IERC20(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC).approve(address(proxy), 100000);
        L1Pool(address(proxy)).StarkingERC20(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC, 100000);
        vm.stopPrank();
    }
}
