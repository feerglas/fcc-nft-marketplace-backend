const { ethers, network } = require('hardhat');
const fs = require('fs');

const frontendContractsFile =
  '../fcc-nft-marketplace-frontend-moralis/constants/networkMapping.json';

async function updateContractAddress() {
  const nftMarketplace = await ethers.getContract('NFTMarketplace');
  const chainId = network.config.chainId.toString();
  const contractAddresses = JSON.parse(
    fs.readFileSync(frontendContractsFile, 'utf8')
  );

  if (chainId in contractAddresses) {
    if (
      !contractAddresses[chainId]['NFTMarketplace'].includes(
        nftMarketplace.address
      )
    ) {
      contractAddresses[chainId]['NFTMarketplace'].push(nftMarketplace.address);
    }
  } else {
    contractAddresses[chainId] = { NFTMarketplace: [nftMarketplace.address] };
  }

  fs.writeFileSync(frontendContractsFile, JSON.stringify(contractAddresses));
}

module.exports = async function () {
  if (process.env.UPDATE_FRONTEND) {
    console.log('--->>> updating frontend');

    await updateContractAddress();
  }
};

module.exports.tags = ['all', 'frontend'];
