const { network } = require('hardhat');
const { developmentChains } = require('../helper-hardhat-config');
const { verify } = require('../utils/verify');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log('####### deploy NftMarketplace #######');
  const arguments = [];
  const nftMarketplace = await deploy('NftMarketplace', {
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
    console.log('####### verify NftMarketplace #######');
    await verify(nftMarketplace.address, arguments);
  }

  console.log('####### end NftMarketplace #######');
};

module.exports.tags = ['all', 'nftMarketplace', 'main'];
