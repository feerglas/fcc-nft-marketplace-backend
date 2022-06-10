const { ethers, network } = require('hardhat');
const { moveBlocks } = require('../utils/move-block');

const TOKEN_ID = 1;

async function cancel() {
  console.log('--->>> Canceling Nft...');

  const nftMarketplace = await ethers.getContract('NFTMarketplace');
  const basicNft = await ethers.getContract('BasicNft');

  const tx = await nftMarketplace.cancelListing(basicNft.address, TOKEN_ID);
  await tx.wait(1);

  console.log('--->>> Nft canceled...');

  if (network.config.chainId == '31337') {
    await moveBlocks(2, (sleepAmount = 1000));
  }
}

cancel()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
