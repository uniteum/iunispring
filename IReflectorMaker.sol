// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/**
 * @title IReflectorMaker
 * @notice Deploy a Reflector clone for a given `(peg, symbol)`. One
 * clone exists per pair, deployed deterministically via
 * CREATE2; {make} deploys (idempotent) and {made} predicts
 * the address without deploying.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface IReflectorMaker {
    /**
     * @notice Emitted when {make} deploys a new clone.
     * @param clone The clone's deterministic CREATE2 address.
     * @param peg The reference token the clone's issues are pegged
     * against (`address(0)` for native ETH).
     * @param symbol The shared symbol every issue minted by the clone
     * carries.
     */
    event Make(address indexed clone, address indexed peg, string symbol);

    /**
     * @notice Thrown by the clone initializer when a clone deployment
     * would duplicate the prototype's own
     * `(native ETH, proto-symbol)` pair. The typed {make}
     * short-circuits that pair to the prototype, so this only
     * surfaces when callers bypass the typed wrapper.
     */
    error ProtoPairReserved();

    /**
     * @notice Thrown when a peg supplied as an {IAddressLookup} resolves
     * to `address(0)` — i.e. the underlying token is not deployed
     * on the current chain. Surfaced by both {made} and {make}
     * so the read and write views fail symmetrically rather than
     * silently substituting native ETH.
     * @param lookup The lookup contract whose `value()` returned zero.
     */
    error UnmappedLookup(address lookup);

    /**
     * @notice Predict the deterministic address of a clone for
     * `(peg, symbol)`. For the proto pair
     * `(native ETH, proto-symbol)` this returns
     * `(true, proto, bytes32(0))` — the prototype itself serves
     * as the canonical factory and no separate clone exists.
     * @param peg The reference token. `address(0)` selects native
     * ETH; an {IAddressLookup} resolves to its
     * `value()` address (the chain-local token); any
     * other address is treated as the token directly.
     * The salt is computed from this raw input, so
     * passing the same {IAddressLookup} on different
     * chains yields the same deterministic clone
     * address even when the resolved token differs.
     * @param symbol The shared symbol every issue minted by the
     * clone would carry.
     * @return exists True if the clone is already deployed (always
     * true for the proto pair).
     * @return home The deterministic clone address (or the
     * prototype for the proto pair).
     * @return salt The CREATE2 salt (`bytes32(0)` for the proto
     * pair, which never uses CREATE2).
     */
    function made(address peg, string calldata symbol) external view returns (bool exists, address home, bytes32 salt);

    /**
     * @notice Deploy a deterministic Reflector clone for
     * `(peg, symbol)`. Idempotent — returns the existing
     * clone if already deployed. For the proto pair
     * `(native ETH, proto-symbol)` this returns the prototype
     * directly (no clone is deployed; the prototype IS the
     * factory for that pair). The clone issues tokens via
     * {IReflector.issue}.
     * @param peg The reference token issues are pegged against. `address(0)`
     * selects native ETH (issues minted with 18
     * decimals); an {IAddressLookup} resolves to its
     * `value()` address (the chain-local token); any
     * other address is treated as the token directly.
     * The salt is computed from this raw input, so
     * the same {IAddressLookup} yields the same clone
     * address across chains.
     * @param symbol Shared symbol every issue minted by this clone
     * will carry.
     * @return clone The deployed (or existing) clone, or the
     * prototype itself for the proto pair.
     */
    function make(address peg, string calldata symbol) external returns (address clone);
}
