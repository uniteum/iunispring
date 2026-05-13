// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/**
 * @title IReflector
 * @notice Issue-token-factory surface of a Reflector instance. Each clone
 *         (and the prototype itself for the native pair) issues per-name
 *         ERC-20s under its stored `(original, symbol)`. Lets callers
 *         depend on a Reflector issuer without pulling in V4 imports.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface IReflector {
    /**
     * @notice Emitted when this instance issues a fresh token via {issue}.
     * @param  clone The instance that issued the token.
     * @param  token The newly issued ERC-20.
     * @param  name  The name carried by the token.
     */
    event Issue(address indexed clone, address indexed token, string name);

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
     * @notice Predict the deterministic address of an issue minted by
     *         the clone for `(original, symbol)` with `name`. Works
     *         whether or not the clone is already deployed.
     * @param  original The reference token, accepted under the same
     *                  rules as {IReflectorMaker.make} / {IReflectorMaker.made}:
     *                  `address(0)` is native ETH; an {IAddressLookup}
     *                  resolves through `value()`; any other address is
     *                  the token itself.
     * @param  symbol   Shared symbol every issue of the clone carries.
     * @param  name     Per-issue name.
     * @return exists   True if the issue token is already deployed.
     * @return home     The deterministic issue address.
     */
    function issued(address original, string calldata symbol, string calldata name)
        external
        view
        returns (bool exists, address home);

    /**
     * @notice Predict the deterministic issue address for `name` under
     *         this instance's stored `(original, symbol)`. Convenience
     *         wrapper for callers that already hold the clone (or the
     *         prototype): the CREATE2 maker for the issue is the
     *         instance itself, so no salt rederivation is needed.
     */
    function issued(string calldata name) external view returns (bool exists, address home);

    /**
     * @notice Mint a fresh issue ERC-20 with `name`, this instance's
     *         stored `symbol`, and decimals + supply derived from
     *         `original`, and seat its entire supply as a single-tick
     *         segment on an {IPlacer}. Idempotent — returns the
     *         existing token if an issue with `name` was already minted
     *         by this instance. Callable on the prototype (mints under
     *         the proto pair `(native ETH, "1x<native>")`) or on any
     *         clone (mints under that clone's pair).
     * @param  name  Per-issue name. Must vary across calls to mint
     *               distinct issues under this instance's
     *               `(original, symbol)`.
     * @return token The minted (or existing) issue ERC-20.
     */
    function issue(string calldata name) external returns (address token);
}
