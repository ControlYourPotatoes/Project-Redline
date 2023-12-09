const InsuranceFactory = artifacts.require("InsuranceFactory");
const fs = require('fs');
const path = require('path');

contract("InsuranceFactory", accounts => {
    it("should simulate hurricane movement towards Puerto Rico", async () => {
        const factory = await InsuranceFactory.deployed();

        // Read mock data from JSON file
        const mockDataPath = path.join(__dirname, '..', 'mockHurricaneData.json');
        const mockData = JSON.parse(fs.readFileSync(mockDataPath, 'utf8'));

        // Loop through mock data and update the contract
        for (const data of mockData) {
            let tx = await factory.updateHurricaneLocation(data.latitude, data.longitude, { from: accounts[0] });
            console.log(`Time: ${data.time}, Transaction: ${tx.tx}`);
        }
    });
});
