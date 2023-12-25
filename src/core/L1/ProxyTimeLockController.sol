// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;
import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title PoolManager
 * @dev PoolManager is a contract for managing the pool
 */
contract ProxyTimeLockController is TimelockController {
    /**
     * @dev constructor
     * @param minDelay The minimum delay for timelock controller
     * @param proposers The proposers for timelock controller
     * @param executors The executors for timelock controller
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {}
}
