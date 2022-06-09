const { network } = require('hardhat');
const { developmentChains } = require('../helper-hardhat-config');
const { verify } = require('../utils/verify');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log('####### deploy NFTMarketplace #######');
  const arguments = [];
  const nftMarketplace = await deploy('NFTMarketplace', {
    from: deployer,
    args: arguments,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  // Verify the deployment
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    console.log('####### verify NFTMarketplace #######');
    await verify(nftMarketplace.address, arguments);
  }

  console.log('####### end NFTMarketplace #######');
};

module.exports.tags = ['all', 'nftmarketplace'];
