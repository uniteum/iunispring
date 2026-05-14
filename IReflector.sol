// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/**
 * @title IReflector
 * @notice Mint a fresh ERC-20 under a fixed `(peg, symbol)`. Each
 * Reflector instance — the prototype for the native pair,
 * or a clone for any other pair — exposes {issue}, which
 * mints one token per name with decimals and supply derived
 * from `peg`.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface IReflector {
    /**
     * @notice Emitted when this instance issues a fresh token via {issue}.
     * @param clone The instance that issued the token.
     * @param token The newly issued ERC-20.
     * @param name The name carried by the token.
     */
    event Issue(address indexed clone, address indexed token, string name);

    /**
     * @notice The reference token every issue minted by this instance is
     * pegged against (`address(0)` for native ETH).
     */
    function peg() external view returns (address);

    /**
     * @notice The shared symbol carried by every issue minted by this
     * instance.
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Predict the deterministic issue address for
     * `(name, variant)` under this instance's stored
     * `(peg, symbol)`. The CREATE2 maker for the issue is the
     * instance itself; callers that hold only `(peg, symbol)`
     * resolve the clone via {IReflectorMaker.made} first, then
     * call {issued} on the result.
     * @param name Per-issue name.
     * @param variant Vanity-mining nonce mixed into the issue's CREATE2
     * salt; different variants for the same `name` yield
     * different issue addresses with identical metadata.
     */
    function issued(string calldata name, uint256 variant) external view returns (bool exists, address home);

    /**
     * @notice Mint a fresh issue ERC-20 with `name`, this instance's
     * stored `symbol`, and decimals + supply derived from
     * `peg`, and list its entire supply as a single-tick
     * segment on an {IPlacer}. Idempotent for a given
     * `(name, variant)` — returns the existing token if one
     * was already minted under those inputs. Callable on the
     * prototype (mints under the proto pair
     * `(native ETH, "1x<native>")`) or on any clone (mints
     * under that clone's pair).
     * @param name Per-issue name.
     * @param variant Vanity-mining nonce mixed into the issue's CREATE2
     * salt; different variants for the same `name` yield
     * different issue addresses with identical metadata.
     * @return token The minted (or existing) issue ERC-20.
     */
    function issue(string calldata name, uint256 variant) external returns (address token);
}
