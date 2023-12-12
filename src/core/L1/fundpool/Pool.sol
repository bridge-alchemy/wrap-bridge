// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../../interfaces/IL1Pool.sol";

contract L1Pool is IL1Pool, AccessControlUpgradeable,PausableUpgradeable, ReentrancyGuardUpgradeable{



    constructor(){
        _disableInitializers();
    }

    function initialize(address _MultisigWallet) public initializer {
        __AccessControl_init();
        __Pausable_init();
        grantRole(DEFAULT_ADMIN_ROLE, _MultisigWallet);


    }



}