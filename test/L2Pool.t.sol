pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "src/testnet/L2/fundpool/Pool.sol";
import "src/testnet/L2/Proxy.sol";
import "src/testnet/L2/ProxyTimeLockController.sol";
import "src/interfaces/IL2Pool.sol";
import "src/Mock/mockWETH.sol";
import "src/Mock/mockERC20.sol";

contract L1fundpoolTest is Test {

    address admin;
    address WithdrawToBridge_Role;


    ProxyTimeLockController proxyTimeLockController;
    Proxy proxy;
    L2Pool l2Pool;
    address ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    mockWETH WETH = new mockWETH();
    mockToken USDT = new mockToken("USDT", "USDT");


    fallback() external payable {}
    receive() external payable {}

    function setUp() public {

        admin = makeAddr("admin");
        WithdrawToBridge_Role = makeAddr("WithdrawToBridge_Role");

        vm.deal(address(this), 100 ether);
        vm.deal(WithdrawToBridge_Role, 100 ether);

        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;


        l2Pool = new L2Pool();
        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
        bytes memory _data = abi.encodeWithSignature("initialize(address)", address(admin));

        proxy = new Proxy(address(l2Pool), address(proxyTimeLockController), _data);
        vm.startPrank(admin);

        L2Pool(address(proxy)).grantRole(l2Pool.WithdrawToBridge_Role(), WithdrawToBridge_Role);
        console.logBytes32(l2Pool.WithdrawToBridge_Role());
        L2Pool(address(proxy)).setValidChainId(11155111, true); // sepolia
        L2Pool(address(proxy)).setValidChainId(534351, true); // Scroll Sepolia
        L2Pool(address(proxy)).setValidChainId(11155420, true); // OP Sepolia
        L2Pool(address(proxy)).setSupportStableCoin(address(WETH), true);
        L2Pool(address(proxy)).setSupportStableCoin(address(USDT), true);


        vm.stopPrank();

        WETH.deposit{value: 10 ether}();
        USDT.mint(address(this), 100000000);

    }

    function test_DepositETHFromScrollToOP()  public {
        L2Pool(address(proxy)).depositETH{value: 0.1 ether}(11155420, address(0x1));


    }

    function test_DepositETHFromOPToScroll()  public {
        L2Pool(address(proxy)).depositETH{value: 0.1 ether}(534351, address(0x1));
    }

    function test_WithdrawETHtoScrollBridge()  public {
        test_DepositETHFromScrollToOP();

        vm.startPrank(WithdrawToBridge_Role);
        L2Pool(address(proxy)).WithdrawETHtoOfficialBridge(address(0x1));
    }

    function test_WithdrawETHtoOPBridge()  public {
        test_DepositETHFromOPToScroll();

        vm.startPrank(WithdrawToBridge_Role);
        L2Pool(address(proxy)).WithdrawETHtoOfficialBridge(address(0x1));
    }
}
