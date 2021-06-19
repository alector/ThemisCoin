/* eslint-disable space-before-function-paren */
/* eslint-disable no-undef */

/*
RUN LIKE THIS:
1st: npx hardhat compile
2nd: npx hardhat run scripts/ThemisICO-deploy.js --network rinkeby 

*/
const hre = require('hardhat');
const { deployed } = require('./deployed');
const { getDeployedAddress } = require('./deployed-get-address');

async function main() {
  const currentContract = 'ThemisICO';
  const coinName = 'ThemisCoin';

  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);

  // We get the contract to deploy
  const MyContract = await hre.ethers.getContractFactory(currentContract);

  const coinAddress = await getDeployedAddress(coinName, hre.network.name);
  console.log('Use the coin is deployed in address:', coinAddress.address);
  const mycontract = await MyContract.deploy(deployer.address, coinAddress.address);

  await mycontract.deployed();

  // save deployed.json
  await deployed(currentContract, hre.network.name, mycontract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
