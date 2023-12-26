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
    address Bridge_ADMIN_ROLE;

    ProxyTimeLockController proxyTimeLockController;
    Proxy proxy;
    L1Pool l1Pool;
    address ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    mockWETH WETH = new mockWETH();
    mockToken USDT = new mockToken("USDT", "USDT");

//    mockWETH WETH = mockWETH(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
//    mockToken USDT = mockToken(0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC);
    fallback() external payable {}
    receive() external payable {}

    function setUp() public {

        admin = makeAddr("admin");
        CompletePools_ROLE = makeAddr("CompletePools_ROLE");
        Bridge_ADMIN_ROLE = makeAddr("Bridge_ADMIN_ROLE");
        vm.deal(address(this), 10 ether);
        vm.deal(CompletePools_ROLE, 100 ether);
        vm.deal(Bridge_ADMIN_ROLE, 100 ether);
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;


        l1Pool = new L1Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));
        proxy = new Proxy(address(l1Pool), address(proxyTimeLockController), _data);
        vm.startPrank(admin);

        uint32 startTimes = uint32(block.timestamp - block.timestamp % 86400 + 86400); // tomorrow
        L1Pool(address(proxy)).setMinStakeAmount(address(ETHAddress), 0.1 ether);
        L1Pool(address(proxy)).grantRole(l1Pool.CompletePools_ROLE(), CompletePools_ROLE);
        L1Pool(address(proxy)).grantRole(l1Pool.Bridge_ADMIN_ROLE(), Bridge_ADMIN_ROLE);

        L1Pool(address(proxy)).SetSupportToken(address(ETHAddress), true, startTimes);
        assert(L1Pool(address(proxy)).getPoolLength(ETHAddress) == 2);
        assert(L1Pool(address(proxy)).getPool(ETHAddress,1).startTimestamp == startTimes);
        assert(L1Pool(address(proxy)).getPool(ETHAddress,1).endTimestamp == startTimes + 3 * 86400);
        L1Pool(address(proxy)).SetSupportToken(address(WETH), true, startTimes);
        L1Pool(address(proxy)).SetSupportToken(address(USDT), true, startTimes);
        vm.stopPrank();

    }


    function test_DepositETH() public {

        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(ETHAddress));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);

    }

    function test_DepositWETH() public {
        WETH.deposit{value: 1 ether}();
        WETH.approve(address(proxy), 1 ether);
        L1Pool(address(proxy)).StakingWETH(1 ether);

        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(WETH));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);
    }

    function test_DepositUSDT() public {
        USDT.mint(address(this), 100000);
        USDT.approve(address(proxy), 100000);
        L1Pool(address(proxy)).StarkingERC20(address(USDT), 100000);

        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 100000);
        assert(_user.token == address(USDT));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);
    }


    function test_ClaimAsset() public {
        uint balanceBefore = address(this).balance;
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        CompletePoolAndNew(address(ETHAddress), 0);

        CompletePoolAndNew(address(ETHAddress), 0.1 ether);
        L1Pool(address(proxy)).ClaimSimpleAsset(ETHAddress);
        uint balanceAfter = address(this).balance;

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }

    function test_ClaimAsset_Staking_twice() public {

        uint balanceBefore = address(this).balance;
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();


        CompletePoolAndNew(address(ETHAddress), 0);
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        CompletePoolAndNew(address(ETHAddress), 0.1 ether);
        CompletePoolAndNew(address(ETHAddress), 0.2 ether);
        L1Pool(address(proxy)).ClaimSimpleAsset(ETHAddress);


        uint balanceAfter = address(this).balance;

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }

    function CompletePoolAndNew(address _token, uint totalFee) public {
        uint latest  = L1Pool(address(proxy)).getPoolLength(_token) - 2;
        vm.warp(L1Pool(address(proxy)).getPool(ETHAddress, latest).endTimestamp);
        vm.startPrank(CompletePools_ROLE);

        IL1Pool.Pool[] memory CompletePools_periodTwo = new IL1Pool.Pool[](1);
        CompletePools_periodTwo[0] = IL1Pool.Pool(0, 0, address(ETHAddress), 0, totalFee, 0, false);
        L1Pool(address(proxy)).CompletePoolAndNew{value: totalFee}(CompletePools_periodTwo);
        vm.stopPrank();

    }

    function test_TransferAssertToScrollBridge() public {
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        vm.startPrank(Bridge_ADMIN_ROLE);
        L1Pool(address(proxy)).TransferAssertToBridge(534351, address(ETHAddress), admin, 0.1 ether);
    }

//    function test_TransferAssertToPolygonZkEvm() public {
//        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
//        vm.startPrank(Bridge_ADMIN_ROLE);
//        L1Pool(address(proxy)).TransferAssertToBridge(1442, address(ETHAddress), admin, 0.1 ether);
//    }

    function test_TransferAssertToOP() public {
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        vm.startPrank(Bridge_ADMIN_ROLE);
        L1Pool(address(proxy)).TransferAssertToBridge(11155420, address(ETHAddress), admin, 0.1 ether);
    }


    }
