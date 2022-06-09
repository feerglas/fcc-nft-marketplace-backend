// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

////////////////////////////////////
// Errors                         //
////////////////////////////////////
error NFTMarketplace__PriceMustBeAboveZero();
error NFTMarketplace__NotApprovedForMarketplace();
error NFTMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NFTMarketplace__NotListed(address nftAddress, uint256 tokenId);
error NFTMarketplace__NotOwner();
error NFTMarketplace__PriceNotMet(
  address nftAddress,
  uint256 tokenId,
  uint256 price
);

contract NFTMarketplace is ReentrancyGuard {
  struct Listing {
    uint256 price;
    address seller;
  }

  ////////////////////////////////////
  // Events                         //
  ////////////////////////////////////
  event ItemListed(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price
  );

  event ItemBought(
    address indexed buyer,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price
  );

  // NFT contract address -> NFT token ID -> Listing
  mapping(address => mapping(uint256 => Listing)) private s_listings;

  // seller address -> amount earned
  mapping(address => uint256) private s_proceeds;

  ////////////////////////////////////
  // Modifiers                      //
  ////////////////////////////////////
  modifier notListed(address nftAddress, uint256 tokenId) {
    Listing memory listing = s_listings[nftAddress][tokenId];
    if (listing.price > 0) {
      revert NFTMarketplace__AlreadyListed(nftAddress, tokenId);
    }
    _;
  }

  modifier isListed(address nftAddress, uint256 tokenId) {
    Listing memory listing = s_listings[nftAddress][tokenId];
    if (listing.price <= 0) {
      revert NFTMarketplace__NotListed(nftAddress, tokenId);
    }
    _;
  }

  modifier isOwner(
    address nftAddress,
    uint256 tokenId,
    address spender
  ) {
    IERC721 nft = IERC721(nftAddress);
    address owner = nft.ownerOf(tokenId);
    if (spender != owner) {
      revert NFTMarketplace__NotOwner();
    }

    _;
  }

  ////////////////////////////////////
  // Main functions                 //
  ////////////////////////////////////

  /**
   * @notice Method for listing your NFT on the marketplace
   * @param nftAddress: Address of the NFT
   * @param tokenId: The Token ID of the NFT
   * @param price: sale price of the listed NFT
   */
  function listItem(
    address nftAddress,
    uint256 tokenId,
    uint256 price
  )
    external
    notListed(nftAddress, tokenId)
    isOwner(nftAddress, tokenId, msg.sender)
  {
    if (price <= 0) {
      revert NFTMarketplace__PriceMustBeAboveZero();

      // 2 possibilities:
      // 1. send the nft to the contract. Transfer -> contract "hold" the nft.
      // 2. owners can still hold their nft, and give the marketplace approval
      // to sell the nft for them.
    }

    IERC721 nft = IERC721(nftAddress);

    if (nft.getApproved(tokenId) != address(this)) {
      revert NFTMarketplace__NotApprovedForMarketplace();
    }

    s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
    emit ItemListed(msg.sender, nftAddress, tokenId, price);
  }

  function buyItem(address nftAddress, uint256 tokenId)
    external
    payable
    nonReentrant
    isListed(nftAddress, tokenId)
  {
    Listing memory listedItem = s_listings[nftAddress][tokenId];
    if (msg.value < listedItem.price) {
      revert NFTMarketplace__PriceNotMet(nftAddress, tokenId, listedItem.price);
    }

    // we don't want to send the money to the seller (push)
    // instead, we want them to actively withdraw it (pull)
    // PULL OVER PUSH
    s_proceeds[listedItem.seller] = s_proceeds[listedItem.seller] + msg.value;
    delete (s_listings[nftAddress][tokenId]);

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // REENTRANCY ATTACK: we call the transfer methd after all the state
    // changes. Doing it before the state changes would be a huge security risk
    //
    // see contracts/playground/ReentrantVulnerable.sol
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    IERC721(nftAddress).safeTransferFrom(
      listedItem.seller,
      msg.sender,
      tokenId
    );
    emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
  }
}

/*

1. `listItem`: List NFTs on the marketplace
2. `buyItem`: Buy NFT
3. `cancelItem`: Cancel a listing
4. `updateListing`: Update Price
5. `withdrawProceeds`: Withdraw payment for sold NFTs

*/
