const main = async () => {
    const contractFactory = await ethers.getContractFactory("NFTwitter");
    const contract = await contractFactory.attach("0xfd328d8f1E133DAcF6a74AD5bADcA1AdFdB3709a");
    
    // debug
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