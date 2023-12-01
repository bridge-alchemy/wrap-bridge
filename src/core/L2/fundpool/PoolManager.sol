// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title PoolManager
 * @dev PoolManager is a contract for managing the pool
 */
contract PoolManager is TimelockController {
    /**
     * @dev constructor
     * @param minDelay The minimum delay for timelock controller
     * @param proposers The proposers for timelock controller
     * @param executors The executors for timelock controller
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) TimelockController(minDelay, proposers, executors) {

    }

}
