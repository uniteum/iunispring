// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/**
 * @title IOwnableMaker
 * @notice Permissionless factory of `Ownable` clones — one per
 * `(owner, variant)`. Anyone calls {make} to deploy a clone
 * owned by an arbitrary address; the clone's owner is the
 * `owner` argument, not `msg.sender`. {made} predicts the
 * deterministic CREATE2 address without deploying.
 * @author Paul Reinholdtsen (reinholdtsen.eth)
 */
interface IOwnableMaker {
    /**
     * @notice Emitted when {make} deploys a new clone.
     * @param owner The address that owns the new clone.
     * @param variant Discriminator under which the clone was deployed.
     * @param home The clone's deterministic CREATE2 address.
     */
    event Made(address indexed owner, uint256 indexed variant, address indexed home);

    /**
     * @notice Predict the deterministic clone address for
     * `(owner, variant)` without deploying.
     * @param owner The address that would own the clone.
     * @param variant Discriminator letting one owner hold multiple clones.
     * @return exists True iff the clone has already been deployed.
     * @return home The predicted (or actual, if `exists`) clone address.
     * @return salt The CREATE2 salt used for the clone.
     */
    function made(address owner, uint256 variant) external view returns (bool exists, address home, bytes32 salt);

    /**
     * @notice Deploy (or return) the clone owned by `owner` under
     * `variant`. One clone exists per `(owner, variant)` pair;
     * repeated calls return the same address. Permissionless:
     * the caller need not be `owner`, so anyone can spin up a
     * clone on behalf of a third party.
     * @param owner The address that will own the clone.
     * @param variant Discriminator letting one owner hold multiple clones.
     * @return instance The clone address. Callers cast to the concrete
     * contract type when they need its full surface.
     */
    function make(address owner, uint256 variant) external returns (address instance);
}
