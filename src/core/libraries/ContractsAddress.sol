// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library ContractsAddress {
    //TODO
    /******************
     **** Arbitrum ****
     *****************/

    address public constant ArbitrumCustomerBridge =
        0x0000000000000000000000000000000000000001; //TODO
    //https://arbiscan.io/token/0x82af49447d8a07e3bd95bd0d56f35241523fbab1
    address public constant ArbitrumWETH =
        0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    //TODO
    /******************
     ***** Linea ******
     *****************/

    address public constant LineaCustomerBridge =
        0x0000000000000000000000000000000000000001; //TODO
    //https://lineascan.build/token/0xe5d7c2a44ffddf6b295a15c148167daaaf5cf34f
    address public constant LineaWETH =
        0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f;

    /*******************
     ** Polygon ZkEVM **
     *******************/
    //https://docs.polygon.technology/zkEVM/architecture/protocol/zkevm-bridge/smart-contracts/

    //https://etherscan.io/address/0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe#readProxyContract
    address public constant PolygonL1CustomerBridge =
        0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
    //https://zkevm.polygonscan.com/address/0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe
    address public constant PolygonL2CustomerBridge =
        0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
    //https://zkevm.polygonscan.com/token/0x4F9A0e7FD2Bf6067db6994CF12E4495Df938E6e9
    address public constant PolygonWETH =
        0x4F9A0e7FD2Bf6067db6994CF12E4495Df938E6e9;

    /******************
     ***** Scroll *****
     *****************/
    //https://docs.scroll.io/en/developers/scroll-contracts/

    //https://etherscan.io/address/0xD8A791fE2bE73eb6E6cF1eb0cb3F36adC9B3F8f9
    address public constant ScrollL1CustomerERC20Bridge =
        0xD8A791fE2bE73eb6E6cF1eb0cb3F36adC9B3F8f9;
    //https://etherscan.io/address/0x7AC440cAe8EB6328de4fA621163a792c1EA9D4fE
    address public constant ScrollL1CustomerWETHBridge =
        0x7AC440cAe8EB6328de4fA621163a792c1EA9D4fE;
    //https://etherscan.io/address/0x7F2b8C31F88B6006c382775eea88297Ec1e3E905#code
    address public constant ScrollL1CustomerETHBridge =
        0x7F2b8C31F88B6006c382775eea88297Ec1e3E905;
    //https://scrollscan.com/address/0xe0a0509a66c509f55c85a20eb8c60676135081f7#code#F8#L47
    address public constant ScrollL2CustomerBridge =
        0x6EA73e05AdC79974B931123675ea8F78FfdacDF0;
    //https://scrollscan.com/token/0x5300000000000000000000000000000000000004
    address public constant ScrollWETH =
        0x5300000000000000000000000000000000000004;
    address public constant ScrollL1MessageQueue =
        0x0d7E906BD9cAFa154b048cFa766Cc1E54E39AF9B;

    /******************
     ***** Optimism ***
     *****************/

    //https://etherscan.io/address/0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1#readProxyContract
    address public constant OptimismL1CustomerBridge =
        0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;
    // https://optimistic.etherscan.io/address/0xc0d3c0d3c0d3c0d3c0d3c0d3c0d3c0d3c0d30010#code#F2#L179
    address public constant OptimismL2CustomerBridge =
        0x4200000000000000000000000000000000000010;

    address public constant OP_LEGACY_ERC20_ETH =
        0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;

    //https://optimistic.etherscan.io/token/0x4200000000000000000000000000000000000006
    address public constant OptimismWETH =
        0x4200000000000000000000000000000000000006;
}
