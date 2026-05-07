// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20Metadata} from "ierc20/IERC20Metadata.sol";

/**
 * @title INotable
 * @notice Issue-token-factory surface of a Notable instance. Each clone
 *         (and the prototype itself for the native pair) issues per-name
 *         ERC-20s under its stored `(original, symbol)`. Lets callers
 *         depend on a Notable issuer without pulling in V4 imports.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface INotable {
    /**
     * @notice Emitted when this instance issues a fresh token via {issue}.
     * @param  clone The instance that issued the token.
     * @param  token The newly issued ERC-20.
     * @param  name  The name carried by the token.
     */
    event Issue(address indexed clone, IERC20Metadata indexed token, string name);

    /**
     * @notice The reference token every issue minted by this instance is
     *         pegged against (`address(0)` for native ETH).
     */
    function original() external view returns (address);

    /**
     * @notice The shared symbol carried by every issue minted by this
     *         instance.
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Predict the deterministic address of the issue the clone
     *         for `(original, symbol)` would mint with `name`. Works
     *         whether or not the clone is already deployed.
     */
    function issued(address original, string calldata symbol, string calldata name)
        external
        view
        returns (bool exists, address home);

    /**
     * @notice Predict the deterministic issue address for `name` under
     *         this instance's stored `(original, symbol)`.
     */
    function issued(string calldata name) external view returns (bool exists, address home);

    /**
     * @notice Mint a fresh issue ERC-20 with `name`, this instance's
     *         stored `symbol`, and decimals + supply derived from
     *         `original`. Idempotent — returns the existing issue if
     *         one with `name` was already minted by this instance.
     */
    function issue(string calldata name) external returns (IERC20Metadata token);
}
