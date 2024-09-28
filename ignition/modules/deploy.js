const { ethers } = require("hardhat");
const { parseUnits, formatBytes32String } = ethers; // Destructure directly from ethers
require('dotenv').config();

const jobId = "53f9755920cd451a8fe46f5087468395";


async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", balance.toString());

    const AstroPet = await ethers.getContractFactory("AstroPet");

    // Deploy the contract with correct references to ethers.parseUnits
    const astroPet = await AstroPet.deploy(
        "0x9ddfaca8183c41ad55329bdeed9f6a8d53168b1b",   // VRF Coordinator
        "0x779877a7b0d9e8603169ddbd7836e478b4624789",   // LINK Token Address
        "0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae",     // Chainlink VRF keyHash
        parseUnits("0.12", 18),               // VRF fee
        "0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD",   // Oracle Address
        jobId, // Chainlink Oracle jobId
        parseUnits("0.1", 18)                  // Oracle fee
    );

    console.log("Contract deployed to:", astroPet.address);
 }
 
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
});
