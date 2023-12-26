pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "src/testnet/L1/fundpool/Pool.sol";
import "src/testnet/L1/Proxy.sol";
import "src/testnet/L1/ProxyTimeLockController.sol";
import "src/interfaces/IL1Pool.sol";
import "src/Mock/mockWETH.sol";
import "src/Mock/mockERC20.sol";

contract L1fundpoolTest is Test {

    address admin;
    address CompletePools_ROLE;

    ProxyTimeLockController proxyTimeLockController;
    Proxy proxy;
    L1Pool l1Pool;

    mockWETH WETH = new mockWETH();
    mockToken USDT = new mockToken("USDT", "USDT");

    function setUp() public {

        admin = makeAddr("admin");
        CompletePools_ROLE = makeAddr("CompletePools_ROLE");
        vm.deal(address(this), 10 ether);
        vm.deal(CompletePools_ROLE, 100 ether);
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;


        l1Pool = new L1Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));
        proxy = new Proxy(address(l1Pool), address(proxyTimeLockController), _data);
        vm.startPrank(admin);

        uint32 startTimes = uint32(block.timestamp - block.timestamp % 86400 + 86400);
        L1Pool(address(proxy)).setMinStakeAmount(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), 0.1 ether);
        L1Pool(address(proxy)).grantRole(l1Pool.CompletePools_ROLE(), address(this));
        L1Pool(address(proxy)).SetSupportToken(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), true, startTimes);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,0).startTimestamp == startTimes);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,0).endTimestamp == startTimes + 3 * 86400);
        L1Pool(address(proxy)).SetSupportToken(address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9), true, startTimes);
        L1Pool(address(proxy)).SetSupportToken(address(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC), true, startTimes);
        vm.stopPrank();

    }


    function test_DepositETH() public {

        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE));
        assert(_user.StartPoolId == 0);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);

    }

    function test_DepositWETH() public {

        WETH.approve(address(proxy), 1 ether);
        L1Pool(address(proxy)).StakingWETH(1 ether);

        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9));
        assert(_user.StartPoolId == 0);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);
    }

    function test_DepositUSDT() public {

        IERC20(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC).approve(address(proxy), 100000);
        L1Pool(address(proxy)).StarkingERC20(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC, 100000);

        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 100000);
        assert(_user.token == address(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC));
        assert(_user.StartPoolId == 0);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);
    }


    function test_ClaimAsset() public {

        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        vm.warp(block.timestamp + 4 * 86400);
        IL1Pool.Pool[] memory CompletePools = new IL1Pool.Pool[](1);
        CompletePools[0] = IL1Pool.Pool(0, 0, address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), 0, 1 ether, 0, false);
        L1Pool(address(proxy)).CompletePoolAndNew{value: 1 ether}(CompletePools);
        assert(L1Pool(address(proxy)).getPoolLength(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) == 2);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 1).TotalAmount == 1 ether);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 1).startTimestamp == L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 0).endTimestamp);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 0).IsCompleted == true);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 1).IsCompleted == false);
        assert(L1Pool(address(proxy)).getPool(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 0).TotalFee == 1 ether);

        L1Pool(address(proxy)).ClaimSimpleAsset(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    }




}
