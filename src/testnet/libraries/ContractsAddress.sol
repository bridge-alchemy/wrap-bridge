// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library ContractsAddress {
    //TODO
    /************************
     **** Arbitrum testnet***
     **********************/

    address public constant ArbitrumCustomerBridge =
        0x0000000000000000000000000000000000000001; //TODO
    //https://arbiscan.io/token/0x82af49447d8a07e3bd95bd0d56f35241523fbab1
    address public constant ArbitrumWETH =
        0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    //TODO
    /************************
     ***** Linea testnet*****
     ***********************/

    address public constant LineaCustomerBridge =
        0x0000000000000000000000000000000000000001; //TODO
    //https://lineascan.build/token/0xe5d7c2a44ffddf6b295a15c148167daaaf5cf34f
    address public constant LineaWETH =
        0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f;

    /*******************
     ** Polygon ZkEVM testnet**
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
     ***** Scroll testnet*****
     *****************/
    //https://docs.scroll.io/en/developers/scroll-contracts/

    //https://sepolia.etherscan.io/address/0x65D123d6389b900d954677c26327bfc1C3e88A13
    address public constant ScrollL1CustomerERC20Bridge =
        0x65D123d6389b900d954677c26327bfc1C3e88A13;
    //https://sepolia.etherscan.io/address/0x3dA0BF44814cfC678376b3311838272158211695
    address public constant ScrollL1CustomerWETHBridge =
        0x3dA0BF44814cfC678376b3311838272158211695;
    //https://sepolia.etherscan.io/address/0x8A54A2347Da2562917304141ab67324615e9866d
    address public constant ScrollL1CustomerETHBridge =
        0x8A54A2347Da2562917304141ab67324615e9866d;
    //https://sepolia.scrollscan.com/address/0x91e8ADDFe1358aCa5314c644312d38237fC1101C
    address public constant ScrollL2CustomerBridge =
        0x91e8ADDFe1358aCa5314c644312d38237fC1101C;
    //https://sepolia.scrollscan.com/address/0x5300000000000000000000000000000000000004
    address public constant ScrollWETH =
        0x5300000000000000000000000000000000000004;
    address public constant ScrollL1MessageQueue =
        0xF0B2293F5D834eAe920c6974D50957A1732de763;

    /******************
     ***** Optimism testnet***
     *****************/
    //https://docs.optimism.io/chain/addresses
    //https://sepolia.etherscan.io/address/0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1
    address public constant OptimismL1CustomerBridge =
        0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1;
    // https://sepolia-optimism.etherscan.io/address/0xc0d3c0d3c0d3c0d3c0d3c0d3c0d3c0d3c0d30010#code#F2#L179
    address public constant OptimismL2CustomerBridge =
        0x4200000000000000000000000000000000000010;

    address public constant OP_LEGACY_ERC20_ETH =
        0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;

    // https://sepolia-optimism.etherscan.io/token/0x4200000000000000000000000000000000000006
    address public constant OptimismWETH =
        0x4200000000000000000000000000000000000006;
}
