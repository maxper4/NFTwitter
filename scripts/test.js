const main = async () => {
    
    const contractFactory = await ethers.getContractFactory("NFTwitter");
    const contract = await contractFactory.attach("0xfd328d8f1E133DAcF6a74AD5bADcA1AdFdB3709a" );
    
    // Now you can call functions of the contract
    const json = await contract.deleteTweet(23);
    console.log(json)
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