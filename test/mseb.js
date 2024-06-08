const {expect} = require("chai");
// const { ethers } = require("hardhat");

describe ("MSEB",()=> {
    let msebContract;
    let owner;
    let user1;
    let ratePerUnit;

    beforeEach(async function() {
        [owner,user1] = await ethers.getSigners();
        const ratePerUnit = 10;
        msebContract = await ethers.deployContract("MSEB",[ratePerUnit]);
        await  msebContract.waitForDeployment();

        console.log(`contract deployed at ${msebContract.target}`);
    });

    it("should register a meter",  async ()=> {
       await msebContract.connect(user1).registerYourMeter(1);
       const meterInfo = await msebContract.meters(1);
       expect(meterInfo.owner).to.equal(user1.address);
       expect(meterInfo.meterId).to.equal(1);
       expect(meterInfo.currentReading).to.equal(0);
       expect(meterInfo.isRegistered).to.equal(true);
    });

    it("Should submit reading and pay bill", async()=>{
        await msebContract.connect(user1).registerYourMeter(1);
        const reading = 60;
        const ratePerUnit =10;
        await msebContract.connect(user1).submitReading(1,reading);
        const amountToPay = reading * ratePerUnit; 
        await msebContract.connect(user1).payBills(1, {value:amountToPay});
        
        console.log("owner balance after pay bill",await msebContract.balances(owner.address));
        expect(await msebContract.balances(owner.address)).to.equal(amountToPay);
    });

});