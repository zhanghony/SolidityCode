const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SecureMessageVerification", function () {
  let secureMessageVerification;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const SecureMessageVerification = await ethers.getContractFactory("SecureMessageVerification");
    secureMessageVerification = await SecureMessageVerification.deploy();
    await secureMessageVerification.waitForDeployment();
  });

  async function signMessage(signer, to, amount, nonce, deadline) {
    const domain = {
      name: "SecureMessageVerification",
      version: "1",
      chainId: (await ethers.provider.getNetwork()).chainId,
      verifyingContract: await secureMessageVerification.getAddress()
    };

    const types = {
      Message: [
        { name: "from", type: "address" },
        { name: "to", type: "address" },
        { name: "amount", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" }
      ]
    };

    const value = {
      from: signer.address,
      to: to,
      amount: amount,
      nonce: nonce,
      deadline: deadline
    };

    const signature = await signer.signTypedData(domain, types, value);
    return ethers.Signature.from(signature);
  }

  it("Should verify and execute a valid message", async function () {
    const to = addr2.address;
    const amount = ethers.parseEther("1");
    const nonce = await secureMessageVerification.getNonce(owner.address);
    const deadline = Math.floor(Date.now() / 1000) + 3600-1; // 1 hour from now

    const { v, r, s } = await signMessage(owner, to, amount, nonce, deadline);

    await expect(secureMessageVerification.verifyAndExecuteMessage(to, amount, deadline, v, r, s))
      .to.emit(secureMessageVerification, "MessageExecuted")
      .withArgs(owner.address, to, amount, nonce);
  });

  it("Should reject an expired message", async function () {
    const to = addr2.address;
    const amount = ethers.parseEther("1");
    const nonce = await secureMessageVerification.getNonce(owner.address);
    const deadline = Math.floor(Date.now() / 1000) - 3600-1; // 1 hour ago

    const { v, r, s } = await signMessage(owner, to, amount, nonce, deadline);

    await expect(secureMessageVerification.verifyAndExecuteMessage(to, amount, deadline, v, r, s))
      .to.be.revertedWith("Signature expired");
  });

  it("Should reject a message with invalid signature", async function () {
    const to = addr2.address;
    const amount = ethers.parseEther("1");
    const nonce = await secureMessageVerification.getNonce(owner.address);
    const deadline = Math.floor(Date.now() / 1000) + 3600-1; // 1 hour from now

    const { v, r, s } = await signMessage(addr1, to, amount, nonce, deadline);

    await expect(secureMessageVerification.verifyAndExecuteMessage(to, amount, deadline, v, r, s))
      .to.be.revertedWith("Invalid signature");
  });

  it("Should reject a message with reused signature", async function () {
    const to = addr2.address;
    const amount = ethers.parseEther("1");
    const nonce = await secureMessageVerification.getNonce(owner.address);
    const deadline = Math.floor(Date.now() / 1000) + 3600-100; // 1 hour from now

    const { v, r, s } = await signMessage(owner, to, amount, nonce, deadline);

    await secureMessageVerification.verifyAndExecuteMessage(to, amount, deadline, v, r, s);

    await expect(secureMessageVerification.verifyAndExecuteMessage(to, amount, deadline, v, r, s))
      .to.be.revertedWith("Signature already used");
  });

  it("Should reject a message with incorrect nonce", async function () {
    const to = addr2.address;
    const amount = ethers.parseEther("1");
    const nonce = (await secureMessageVerification.getNonce(owner.address)) + 1n; // Incorrect nonce
    const deadline = Math.floor(Date.now() / 1000) + 3600-1; // 1 hour from now

    const { v, r, s } = await signMessage(owner, to, amount, nonce, deadline);

    await expect(secureMessageVerification.verifyAndExecuteMessage(to, amount, deadline, v, r, s))
      .to.be.revertedWith("Invalid signature");
  });
});