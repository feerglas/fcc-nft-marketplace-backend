const { ethers, network } = require('hardhat');
const { moveBlocks } = require('../utils/move-block');

const PRICE = ethers.utils.parseEther('0.1');

async function mint() {
  const nftMarketplace = await ethers.getContract('NFTMarketplace');
  const basicNft = await ethers.getContract('BasicNft');

  console.log('--->>> Minting Nft...');

  const mintTx = await basicNft.mintNft();
  const mintTxReceipt = await mintTx.wait(1);

  if (network.config.chainId == '31337') {
    await moveBlocks(1, (sleepAmount = 1000));
  }
}

mint()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
