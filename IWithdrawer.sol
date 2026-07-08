// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/**
 * @title IWithdrawer
 * @notice Pull a contract's currency balance out to its owner.
 * {withdraw} sends `amount` of `currency` to the owner
 * (owner-only); {Withdrawn} logs each pull.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface IWithdrawer {
    /**
     * @notice Emitted when {withdraw} sends a balance to the owner.
     * @param currency The currency withdrawn (`address(0)` for native ETH).
     * @param amount The amount sent.
     */
    event Withdrawn(address indexed currency, uint256 amount);

    /**
     * @notice Pull `amount` of `currency` from the contract's balance and
     * send it to its owner. Owner-only.
     */
    function withdraw(address currency, uint256 amount) external;
}
