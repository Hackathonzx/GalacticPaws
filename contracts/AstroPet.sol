// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AstroPet is ERC721, Ownable {
    struct AstroPetAttributes {
        uint256 size;
        uint256 color;
        uint256 power;
        uint256 level;
        uint256 experience;
        bool evolved;
    }

    struct RareItem {
        string name;
        uint256 rarity; // Rarity score from 1-100
    }

    // Mapping to store AstroPet attributes
    mapping(uint256 => AstroPetAttributes) public astroPets;
    mapping(uint256 => uint256) public missionStartBlock;
    mapping(uint256 => uint256) public playerInput;  // Store player input for each pet's mission

    // Mapping to store rare items found by AstroPets
    mapping(uint256 => RareItem) public rareItemsFound;

    event MissionOutcome(uint256 petId, string outcome, string rareItem);

    constructor() ERC721("AstroPet", "APET") {}

    // Function to mint new AstroPets
    function mintAstroPet(uint256 petId) external onlyOwner {
        _mint(msg.sender, petId);
        astroPets[petId] = AstroPetAttributes({
            size: 1,
            color: uint256(keccak256(abi.encodePacked(block.timestamp))) % 256,
            power: 10,
            level: 1,
            experience: 0,
            evolved: false
        });
    }

    // Function to initiate a space mission with player input
    // `missionPath` represents different mission paths the player can choose from
    function startMission(uint256 petId, uint256 missionPath) external {
        require(ownerOf(petId) == msg.sender, "You don't own this AstroPet.");
        require(missionPath >= 1 && missionPath <= 3, "Invalid mission path.");
        missionStartBlock[petId] = block.number;
        playerInput[petId] = missionPath;
    }

    // Function to finalize the mission and update the AstroPet's stats
    function finalizeMission(uint256 petId) external {
        require(block.number > missionStartBlock[petId] + 5, "Wait for a few blocks.");

        // Generate randomness using player input and block hash of future block
        uint256 randomness = uint256(keccak256(abi.encodePacked(
            playerInput[petId],                 // Include player's input in randomness
            blockhash(missionStartBlock[petId] + 5),  // Block hash of a future block
            block.timestamp,                    // Extra layer of randomness
            msg.sender                          // Player's address for additional entropy
        )));

        // Determine the outcome of the mission based on the randomness
        string memory outcome;
        string memory foundItem = "";

        if (randomness % 2 == 0) {
            // Success: AstroPet gains experience and has a chance to evolve
            astroPets[petId].experience += 10;
            astroPets[petId].level += 1;

            if (astroPets[petId].experience >= 50 && !astroPets[petId].evolved) {
                astroPets[petId].evolved = true;
                astroPets[petId].power += 20; // Pet evolves and becomes stronger
                outcome = "AstroPet evolved and became stronger!";
            } else {
                outcome = "AstroPet successfully completed the mission!";
            }

            // Check for rare item discovery based on mission path
            if (randomness % 100 < 10) {
                RareItem memory rareItem = discoverRareItem(randomness);
                rareItemsFound[petId] = rareItem;
                foundItem = rareItem.name;
                outcome = string(abi.encodePacked(outcome, " Found rare item: ", rareItem.name));
            }
        } else {
            // Failure: AstroPet loses some power
            astroPets[petId].power -= 2;
            outcome = "AstroPet failed the mission.";
        }

        emit MissionOutcome(petId, outcome, foundItem);
    }

    // Function to discover a rare item during a mission
    function discoverRareItem(uint256 randomness) internal pure returns (RareItem memory) {
        uint256 rarity = (randomness % 100) + 1;  // Random rarity between 1-100
        string memory name;

        if (rarity <= 10) {
            name = "Cosmic Crystal";
        } else if (rarity <= 50) {
            name = "Interstellar Gem";
        } else {
            name = "Galactic Stone";
        }

        return RareItem({
            name: name,
            rarity: rarity
        });
    }

    // Function to engage in a space battle with another player's AstroPet
    function battle(uint256 petId, uint256 opponentId) external {
        require(ownerOf(petId) == msg.sender, "You don't own this AstroPet.");
        require(ownerOf(opponentId) != msg.sender, "Cannot battle your own pet.");

        AstroPetAttributes storage pet = astroPets[petId];
        AstroPetAttributes storage opponent = astroPets[opponentId];

        uint256 petPower = pet.power + pet.level;
        uint256 opponentPower = opponent.power + opponent.level;

        if (petPower > opponentPower) {
            pet.experience += 20;
            pet.level += 1;
            emit MissionOutcome(petId, "AstroPet won the space battle!", "");
        } else {
            pet.power -= 1;
            emit MissionOutcome(petId, "AstroPet lost the space battle.", "");
        }
    }
}
