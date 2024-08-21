const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleAuction", function () {
  let SimpleAuction;
  let simpleAuction;
  let owner;
  let bidder1;
  let bidder2;
  let beneficiary;

  const ONE_DAY = 24 * 60 * 60;

  beforeEach(async function () {
    [owner, bidder1, bidder2, beneficiary] = await ethers.getSigners();

    SimpleAuction = await ethers.getContractFactory("SimpleAuction");
    simpleAuction = await SimpleAuction.deploy(ONE_DAY, beneficiary.address);
    await simpleAuction.waitForDeployment();
  });

  describe("Deployment", function () {
    it("should set the beneficiary correctly", async function () {
      expect(await simpleAuction.beneficiary()).to.equal(beneficiary.address);
    });

    it("should set the auction end time correctly", async function () {
      const deploymentTime = await ethers.provider.getBlock("latest").then(block => block.timestamp);
      const endTime = await simpleAuction.auctionEndTime();
      expect(endTime).to.equal(deploymentTime + ONE_DAY);
    });
  });

  describe("Bidding", function () {
    it("should allow bids and update highest bidder", async function () {
      await simpleAuction.connect(bidder1).bid({ value: ethers.parseEther("1") });
      expect(await simpleAuction.highestBidder()).to.equal(bidder1.address);
      expect(await simpleAuction.highestBid()).to.equal(ethers.parseEther("1"));

      await simpleAuction.connect(bidder2).bid({ value: ethers.parseEther("2") });
      expect(await simpleAuction.highestBidder()).to.equal(bidder2.address);
      expect(await simpleAuction.highestBid()).to.equal(ethers.parseEther("2"));
    });

    it("should reject bids that are not high enough", async function () {
      await simpleAuction.connect(bidder1).bid({ value: ethers.parseEther("1") });
      await expect(
        simpleAuction.connect(bidder2).bid({ value: ethers.parseEther("0.5") })
      ).to.be.revertedWith("BidNotHighEnough");
    });

    it("should reject bids after the auction has ended", async function () {
      await ethers.provider.send("evm_increaseTime", [ONE_DAY + 1]);
      await ethers.provider.send("evm_mine");

      await expect(
        simpleAuction.connect(bidder1).bid({ value: ethers.parseEther("1") })
      ).to.be.revertedWith("AuctionAlreadyEnded");
    });
  });

  describe("Withdrawal", function () {
    it("should allow non-highest bidders to withdraw", async function () {
      await simpleAuction.connect(bidder1).bid({ value: ethers.parseEther("1") });
      await simpleAuction.connect(bidder2).bid({ value: ethers.parseEther("2") });

      const initialBalance = await ethers.provider.getBalance(bidder1.address);
      await simpleAuction.connect(bidder1).withdraw();
      const finalBalance = await ethers.provider.getBalance(bidder1.address);

      expect(finalBalance).to.be.gt(initialBalance);
    });

    it("should not allow withdrawal for addresses with no pending returns", async function () {
      await expect(simpleAuction.connect(bidder1).withdraw()).to.be.revertedWith("No funds to withdraw");
    });
  });

  describe("Ending the auction", function () {
    it("should only allow ending the auction after the end time", async function () {
      await expect(simpleAuction.auctionEnd()).to.be.revertedWith("AuctionNotYetEnded");

      await ethers.provider.send("evm_increaseTime", [ONE_DAY + 1]);
      await ethers.provider.send("evm_mine");

      await expect(simpleAuction.auctionEnd()).not.to.be.reverted;
    });

    it("should transfer the highest bid to the beneficiary", async function () {
      await simpleAuction.connect(bidder1).bid({ value: ethers.parseEther("1") });

      await ethers.provider.send("evm_increaseTime", [ONE_DAY + 1]);
      await ethers.provider.send("evm_mine");

      const initialBalance = await ethers.provider.getBalance(beneficiary.address);
      await simpleAuction.auctionEnd();
      const finalBalance = await ethers.provider.getBalance(beneficiary.address);

      expect(finalBalance - initialBalance).to.equal(ethers.parseEther("1"));
    });

    it("should not allow ending the auction multiple times", async function () {
      await ethers.provider.send("evm_increaseTime", [ONE_DAY + 1]);
      await ethers.provider.send("evm_mine");

      await simpleAuction.auctionEnd();
      await expect(simpleAuction.auctionEnd()).to.be.revertedWith("AuctionEndAlreadyCalled");
    });
  });
});