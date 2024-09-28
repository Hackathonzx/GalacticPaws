const hre = require("hardhat");

async function main() {
  // Retrieve the contract factory for the AstroPet contract
  const AstroPet = await hre.ethers.getContractFactory("AstroPet");

  // Deploy the contract without constructor parameters
  const astroPet = await AstroPet.deploy();

  // Wait for the contract to be deployed
  await astroPet.waitForDeployment(); // Updated for ethers v6
  console.log("AstroPet deployed to:", await astroPet.getAddress()); // Updated for ethers v6
}

// Main function to call the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
