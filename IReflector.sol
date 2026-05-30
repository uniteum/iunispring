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
     * @notice Thrown by {issue} when the caller-supplied `supply` exceeds
     * the instance's {maxSupply} cap.
     * @param supply The requested supply.
     * @param maxSupply The configured cap.
     */
    error SupplyExceedsMaxSupply(uint256 supply, uint128 maxSupply);

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
     * @notice Hard cap on the supply a caller may request through {issue}.
     * Sized to fit V4's `maxLiquidityPerTick` for a single-tick
     * seat at `tickSpacing = 1`, so any `supply <= maxSupply`
     * is guaranteed to land in the pool.
     */
    function maxSupply() external view returns (uint128);

    /**
     * @notice Predict the deterministic issue address for
     * `(name, supply, variant)` under this instance's stored
     * `(peg, symbol)`. The CREATE2 maker for the issue is the
     * instance itself; callers that hold only `(peg, symbol)`
     * resolve the clone via {IReflectorMaker.made} first, then
     * call {issued} on the result.
     * @param name Per-issue name.
     * @param supply Raw token supply the caller would mint; mixed into
     * the issue's CREATE2 salt, so the same `(name, variant)`
     * at a different `supply` predicts a different address.
     * @param variant Vanity-mining nonce mixed into the issue's CREATE2
     * salt; different variants for the same `name` yield
     * different issue addresses with identical metadata.
     */
    function issued(string calldata name, uint256 supply, uint256 variant)
        external
        view
        returns (bool exists, address home);

    /**
     * @notice Mint a fresh issue ERC-20 with `name`, this instance's
     * stored `symbol`, decimals derived from `peg`, and the
     * caller-supplied `supply`. The entire supply is listed as
     * a single-tick segment on an {IPlacer}. Idempotent for a
     * given `(name, supply, variant)` — returns the existing
     * token if one was already minted under those inputs.
     * Callable on the prototype (mints under the proto pair
     * `(native ETH, "1x<native>")`) or on any clone (mints
     * under that clone's pair). Reverts with
     * {SupplyExceedsMaxSupply} when `supply > maxSupply`.
     * @param name Per-issue name.
     * @param supply Raw token supply to mint and seat in the pool. Must
     * not exceed {maxSupply}.
     * @param variant Vanity-mining nonce mixed into the issue's CREATE2
     * salt; different variants for the same `name` yield
     * different issue addresses with identical metadata.
     * @return token The minted (or existing) issue ERC-20.
     */
    function issue(string calldata name, uint256 supply, uint256 variant) external returns (address token);
}
