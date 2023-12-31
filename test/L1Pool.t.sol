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



        vm.startPrank(CompletePools_ROLE);
        WETH.deposit{value: 10 ether}();
        USDT.mint(CompletePools_ROLE, 100000000);
        vm.stopPrank();

    }


    function test_StakingETH() public {

        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        assert(L1Pool(address(proxy)).getUserLength(address(this)) == 1);
        IL1Pool.User memory _user = L1Pool(address(proxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(ETHAddress));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isClaimed == false);

    }

    function test_StakingWETH() public {
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

    function test_StakingUSDT() public {

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


    function test_ClaimETH() public {
        uint balanceBefore = address(this).balance;
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        CompleteETHPoolAndNew(address(ETHAddress), 0);

        CompleteETHPoolAndNew(address(ETHAddress), 0.1 ether);
        L1Pool(address(proxy)).ClaimSimpleAsset(ETHAddress);
        uint balanceAfter = address(this).balance;

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }

    function test_ClaimETH_Staking_twice() public {

        uint balanceBefore = address(this).balance;
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();


        CompleteETHPoolAndNew(address(ETHAddress), 0);
        L1Pool(address(proxy)).StakingETH{value: 1 ether}();
        CompleteETHPoolAndNew(address(ETHAddress), 0.1 ether);
        CompleteETHPoolAndNew(address(ETHAddress), 0.2 ether);
        L1Pool(address(proxy)).ClaimSimpleAsset(ETHAddress);


        uint balanceAfter = address(this).balance;

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }

    function test_ClaimWETH() public{
        WETH.deposit{value: 1 ether}();
        uint balanceBefore = WETH.balanceOf(address(this));
        WETH.approve(address(proxy), 0.1 ether);
        L1Pool(address(proxy)).StakingWETH(0.1 ether);
        CompleteWETHPoolAndNew(address(WETH), 0);

        CompleteWETHPoolAndNew(address(WETH), 0.1 ether);
        
        L1Pool(address(proxy)).ClaimSimpleAsset(address(WETH));
        uint balanceAfter =  WETH.balanceOf(address(this));

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }


    function test_ClaimUSDT() public{

        uint balanceBefore = USDT.balanceOf(address(this));
        USDT.approve(address(proxy), 10000);
        L1Pool(address(proxy)).StarkingERC20(address(USDT), 10000);
        CompleteUSDTPoolAndNew(address(USDT), 0);

        CompleteUSDTPoolAndNew(address(USDT), 100);

        L1Pool(address(proxy)).ClaimSimpleAsset(address(USDT));
        uint balanceAfter =  USDT.balanceOf(address(this));

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }


    function CompleteETHPoolAndNew(address _token, uint totalFee) internal {
        uint latest  = L1Pool(address(proxy)).getPoolLength(_token) - 2;
        vm.warp(L1Pool(address(proxy)).getPool(ETHAddress, latest).endTimestamp);
        vm.startPrank(CompletePools_ROLE);

        IL1Pool.Pool[] memory CompletePools_period = new IL1Pool.Pool[](1);
        CompletePools_period[0] = IL1Pool.Pool(0, 0, address(ETHAddress), 0, totalFee, 0, false);
        L1Pool(address(proxy)).CompletePoolAndNew{value: totalFee}(CompletePools_period);
        vm.stopPrank();

    }

    function CompleteWETHPoolAndNew(address _token, uint totalFee) internal {
        uint latest  = L1Pool(address(proxy)).getPoolLength(_token) - 2;
        vm.warp(L1Pool(address(proxy)).getPool(address(WETH), latest).endTimestamp);
        vm.startPrank(CompletePools_ROLE);

        IL1Pool.Pool[] memory CompletePools_period = new IL1Pool.Pool[](1);
        CompletePools_period[0] = IL1Pool.Pool(0, 0, address(WETH), 0, totalFee, 0, false);
        L1Pool(address(proxy)).CompletePoolAndNew(CompletePools_period);
        WETH.transfer(address(proxy), totalFee);

        vm.stopPrank();

    }


    function CompleteUSDTPoolAndNew(address _token, uint totalFee) internal {
        uint latest  = L1Pool(address(proxy)).getPoolLength(_token) - 2;
        vm.warp(L1Pool(address(proxy)).getPool(address(USDT), latest).endTimestamp);
        vm.startPrank(CompletePools_ROLE);

        IL1Pool.Pool[] memory CompletePools_period = new IL1Pool.Pool[](1);
        CompletePools_period[0] = IL1Pool.Pool(0, 0, address(USDT), 0, totalFee, 0, false);
        L1Pool(address(proxy)).CompletePoolAndNew(CompletePools_period);
        USDT.transfer(address(proxy), totalFee);

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
