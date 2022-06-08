// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

////////////////////////////////////
// Errors                         //
////////////////////////////////////
error NFTMarketplace__PriceMustBeAboveZero();
error NFTMarketplace__NotApprovedForMarketplace();
error NFTMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NFTMarketplace__NotOwner();

contract NFTMarketplace {
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

  // NFT contract address -> NFT token ID -> Listing
  mapping(address => mapping(uint256 => Listing)) private s_listings;

  ////////////////////////////////////
  // Modifiers                      //
  ////////////////////////////////////
  modifier notListed(
    address nftAddress,
    uint256 tokenId,
    address owner
  ) {
    Listing memory listing = s_listings[nftAddress][tokenId];
    if (listing.price > 0) {
      revert NFTMarketplace__AlreadyListed(nftAddress, tokenId);
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
    notListed(nftAddress, tokenId, msg.sender)
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
}

/*

1. `listItem`: List NFTs on the marketplace
2. `buyItem`: Buy NFT
3. `cancelItem`: Cancel a listing
4. `updateListing`: Update Price
5. `withdrawProceeds`: Withdraw payment for sold NFTs

*/
