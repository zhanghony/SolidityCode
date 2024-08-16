import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JAN_1ST_2030 = 1893456000;
const ONE_GWEI: bigint = 1_000_000_000n;

const TestModule = buildModule("TestModule", (m) => {
  const unlockTime = m.getParameter("unlockTime", JAN_1ST_2030);
  const lockedAmount = m.getParameter("lockedAmount", ONE_GWEI);
  const address = 0x40340F24338dc5DFFe9338Be1A114A768541AEe7;

  //合同
  const test = m.contract("Test", [], {
    value: lockedAmount,
  });

  console.log("%s  %s",test,ONE_GWEI)

 


  return { test };
});

export default TestModule;
