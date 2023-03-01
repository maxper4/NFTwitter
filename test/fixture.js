const { ethers } = require("hardhat");

async function setupFixture() {
    const [owner, royaltiesAccount, author, buyer] = await ethers.getSigners();

    const contractFactory = await hre.ethers.getContractFactory('NFTwitter');
    
    const contract = await contractFactory.deploy(royaltiesAccount.address);
  
    return {
        owner,
        royaltiesAccount,
        buyer,
        author,
        contract
    }
}


module.exports = {
    setupFixture
}