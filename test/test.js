const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");

  describe("TEST", function () {


    async function deployOneYearLockFixture() {
        const ONE_YEAR_IN_SECS = 20;
        const ONE_GWEI = 1_000_000_000;
    
        const lockedAmount = ONE_GWEI;
        const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;
    
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();
    
        const Test = await ethers.getContractFactory("Test");
        const test = await Test.deploy();
    
        return { test, unlockTime, lockedAmount, owner, otherAccount };
      }

    
  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { test } = await loadFixture(deployOneYearLockFixture);

      

      let rewardsStart = await time.latest()+20;
      console.log(rewardsStart);

      await time.increaseTo(rewardsStart);
      const currentTimestamp = await time.latest();
      console.log("Current timestamp:", currentTimestamp.toString()); // 确认时间戳

      time.setNextBlockTimestamp(rewardsStart);

// 手动设置下一个区块的时间戳
// await ethers.provider.send("evm_setNextBlockTimestamp", [rewardsStart]);
// await ethers.provider.send("evm_mine");
      await test.stake(200);

     
    });

    
  });



  });