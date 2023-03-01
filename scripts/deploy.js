const main = async () => {
    const [deployer] = await hre.ethers.getSigners();
    const contractFactory = await hre.ethers.getContractFactory('NFTwitter');
    
    const contract = await contractFactory.deploy(deployer.address);
  
    await contract.deployed();
    console.log("Contract deployed to:", contract.address);
};
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();