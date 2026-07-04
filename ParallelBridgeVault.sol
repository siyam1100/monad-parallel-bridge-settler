// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ParallelBridgeVault
 * @dev Manages asset cross-chain unlocks across isolated storage variables to maximize concurrency profiles.
 */
contract ParallelBridgeVault is Ownable {

    address public tokenAsset;
    // Track claim flags in an isolated layout to ensure clean parallel lookups
    mapping(bytes32 => bool) public processedClaims;

    event TokensUnlocked(bytes32 indexed claimId, address indexed recipient, uint256 amount);

    constructor(address _tokenAsset) Ownable(msg.sender) {
        tokenAsset = _tokenAsset;
    }

    /**
     * @notice Finalizes token claims concurrently.
     * @dev Independent claims do not overlap in storage slots, preventing OCC engine rollbacks.
     */
    function unlockCrossChainAssets(
        bytes32 claimId,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(!processedClaims[claimId], "BridgeError: Cryptographic claim hash already processed");
        
        processedClaims[claimId] = true;
        IERC20(tokenAsset).transfer(recipient, amount);

        emit TokensUnlocked(claimId, recipient, amount);
    }
}
