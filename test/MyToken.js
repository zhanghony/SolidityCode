const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const { boolean } = require("hardhat/internal/core/params/argumentTypes");
 
 

describe("MyToken", function () {
  async function deployFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();
    console.log("owner:", owner.address);
    console.log("otherAccount:", otherAccount.address);

    // const MyToken = await hre.ethers.getContractFactory("MyToken");

    const _name = "MyToken";
    const _symbol = "MyToken";
    const _decimals = 18;
    const _totalSupply = 100000000;

    const mytoken = await ethers.deployContract("MyToken", [
      _name,
      _symbol,
      _decimals,
      _totalSupply,
    ]);
    console.log(`deploy mytoken to : ${mytoken.target}`);

    mytoken.on("Transfer", (from, to, value) => {
        console.log("Transfer ", from, to, value);
      });

    const Faucet = await ethers.getContractFactory("Faucet");
    const amountEatchTime = 20;
    const faucet = await Faucet.deploy(mytoken.target, amountEatchTime);
    console.log("deploy faucet:", faucet.target);

    const Airdrop = await ethers.getContractFactory("Airdrop");
    const aridrop = await Airdrop.deploy(mytoken.target);
    console.log("deploy aridrop:", aridrop.target);
    return { mytoken, _totalSupply, faucet, aridrop, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right totalSupply", async function () {
      const { mytoken, _totalSupply } = await loadFixture(deployFixture);

      expect(await mytoken.totalSupply()).to.equal(_totalSupply);
    });
  });

  describe("Approve", function () {
    it("approve success", async function () {
      const { mytoken, _totalSupply, faucet, aridrop, owner, otherAccount } =
        await loadFixture(deployFixture);
 
      // let success = await mytoken.transfer(aridrop.target, 10000000);
      // console.log("success :" ,success);

      let tx = await mytoken.transfer(aridrop.target, 10000000);
      let receipt = await tx.wait();
      console.log("Transfer successful:", receipt.status === 1);

      expect(await mytoken.balanceOf(aridrop.target)).to.equal(10000000);

      await aridrop.oneToOne([faucet.target], [10000000]);
      console.log("balanceOf faucet:", await mytoken.balanceOf(faucet.target));

      await mytoken.approve(faucet.target, 10000000).then(res=>{
        console.log(res.value);

      });
     
      console.log(
        "balanceOf otherAccount before:",
        await mytoken.balanceOf(otherAccount.address)
      );
      await faucet.connect(otherAccount).withdrow();
      console.log(
        "balanceOf otherAccount after:",
        await mytoken.balanceOf(otherAccount.address)
      );

      expect(await faucet.amountEachTime()).to.equal(
        await mytoken.balanceOf(otherAccount.address)
      );

      await expect(faucet.connect(otherAccount).withdrow()).to.be.revertedWith(
        "You can only request tokens once every 24 hours"
      );

      const tomorrow = (await time.latest()) + 24 * 60 * 60;

      await time.increaseTo(tomorrow);


      await expect(faucet.connect(otherAccount).withdrow()).not.to.be.reverted;
 
    });
  });

  //   describe("Transfer",async function () {
  //     const { mytoken,_totalSupply,faucet,aridrop } = await loadFixture(deployFixture);
  //     it("",async function () {

  //     });

  //   });
});
