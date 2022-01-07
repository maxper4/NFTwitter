const main = async () => {
    const contractFactory = await hre.ethers.getContractFactory('NFTwitter');
    
    const contract = await contractFactory.deploy();
  
    await contract.deployed();
    console.log("Contract deployed to:", contract.address);

    await contract.tweet("Tweet", 0)
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