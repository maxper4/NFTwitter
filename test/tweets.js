const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { setupFixture } = require("./fixture.js");

describe("NFTwitter", function () {
    it("Should post a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello World", 0);
        const tweet = await contract.connect(author).tweets(1);
        expect(tweet.content).to.equal("Hello World");
    });

    it("Should delete a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello World", 0);
        await contract.connect(author).deleteTweet(1);
        const tweet = await contract.connect(author).tweets(1);
        expect(tweet.content).to.equal("");
    });

    it("Should like a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello World", 0);
        await contract.connect(buyer).likeTweet(1);
        const tweet = await contract.connect(author).tweets(1);
        expect(tweet.likes).to.equal(1);
    });

    it("Should unlike a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello World", 0);
        await contract.connect(buyer).likeTweet(1);
        let tweet = await contract.connect(author).tweets(1);
        expect(tweet.likes).to.equal(1);

        await contract.connect(buyer).unlikeTweet(1);
        tweet = await contract.connect(author).tweets(1);
        expect(tweet.likes).to.equal(0);
    });

    it("Should reply to a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello ...", 0);
        await contract.connect(buyer).tweet("World !", 1);
        const tweet = await contract.connect(author).tweets(2);
        expect(tweet.content).to.equal("World !");
        expect(tweet.parentId).to.equal(1);
    });

    it("Should tip a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello World", 0);

        const balanceContractBefore = await hre.ethers.provider.getBalance(contract.address);
        const balanceAuthorBefore = await hre.ethers.provider.getBalance(author.address);
        const balanceBuyerBefore = await hre.ethers.provider.getBalance(buyer.address);
        const balanceRoyaltiesAccountBefore = await hre.ethers.provider.getBalance(royaltiesAccount.address);

        const tx = await contract.connect(buyer).tipTweet(1, { value: 1000 });
        const res = await tx.wait();
        
        const balanceContractAfter = await hre.ethers.provider.getBalance(contract.address);
        const balanceAuthorAfter = await hre.ethers.provider.getBalance(author.address);
        const balanceBuyerAfter = await hre.ethers.provider.getBalance(buyer.address);
        const balanceRoyaltiesAccountAfter = await hre.ethers.provider.getBalance(royaltiesAccount.address);

        expect(balanceContractAfter).to.equal(balanceContractBefore);
        expect(balanceAuthorAfter).to.equal(balanceAuthorBefore.add(1000 - 1000 * 10 / 100));
        expect(balanceBuyerAfter).to.equal(balanceBuyerBefore.sub(1000).sub(res.gasUsed * res.effectiveGasPrice));
        expect(balanceRoyaltiesAccountAfter).to.equal(balanceRoyaltiesAccountBefore.add(1000 * 10 / 100));
    });

    it("Should transfer a tweet", async function () {
        const { owner, royaltiesAccount, author, buyer, contract } = await loadFixture(setupFixture);

        await contract.connect(author).tweet("Hello World", 0);
        await contract.connect(author).transferFrom(author.address, buyer.address, 1);
        const tweet = await contract.connect(buyer).tweets(1);
        expect(tweet.author).to.equal(author.address);
        expect(tweet.owner).to.equal(buyer.address);
    });
});