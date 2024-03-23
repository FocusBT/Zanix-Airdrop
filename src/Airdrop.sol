// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Airdrop {
    bytes32 public merkleRoot;
    mapping(address => bool) public hasClaimed;
    IERC20 public ZANIX;
    IERC20 public USD;
    address public owner;

    constructor(bytes32 _merkleRoot) {
        ZANIX = IERC20(0xf96fF891F0c271a89Dae17346791B1FA524fC681);
        USD = IERC20(0x55d398326f99059fF775485246999027B3197955);
        merkleRoot = _merkleRoot;
        owner = msg.sender;
    }

    function claimAirdrop(bytes32[] calldata proof) public {
        require(!hasClaimed[msg.sender], "Airdrop already claimed.");
        require(USD.allowance(msg.sender, address(this)) >= 1800000000000000000, "Insufficient Allowence");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(verify(proof, leaf), "Invalid proof.");
        USD.transferFrom(msg.sender, owner, 1800000000000000000);
        ZANIX.transfer(msg.sender, 3000000000000000000000);
        hasClaimed[msg.sender] = true;
    }

    function verify(bytes32[] memory proof, bytes32 leaf) internal view returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == merkleRoot;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(owner != newOwner, "Invalid Address");
        owner = newOwner;
    }
}
