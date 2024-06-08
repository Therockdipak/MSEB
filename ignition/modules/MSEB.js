const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MSEB", (m) => {
  const mseb = m.contract("MSEB", [100]);

  // m.call(mseb, "registerYourMeter", [55]);

  return { mseb };
});

// 0x5FbDB2315678afecb367f032d93F642f64180aa3