// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./NFTRoyality.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nftsale is Ownable {
    mapping (address => mapping (uint256 => listing)) public listings;
    mapping (address => uint256) public balances;

    struct listing {
        uint256 price;
        address seller;
   }


   function addlisting(uint256 price, address contractAddress, uint256 tokenId) public {
       NFTRoyality token =NFTRoyality(contractAddress);
       require(token.balanceOf(msg.sender, tokenId) > 0, "Must Own token");
       require(token.isApprovedForAll(msg.sender, address(this)), "Must be Approved");

       listings[contractAddress][tokenId] = listing(price, msg.sender);
       
    }

    function purchase(address from, uint256 tokenId, uint256 amount) public payable {
        listing memory item = listings[from][tokenId];
        require(msg.value >= item.price * amount, "Insufficient Fund Send");
        balances[item.seller] += msg.value;

        NFTRoyality token =NFTRoyality(from);
        token.safeTransferFrom(item.seller, msg.sender, tokenId, amount, "");
        
        
    }

    
    
    function Withdraw() public onlyOwner {
        require(address(this).balance > 0, "Zero Balance");
        payable(msg.sender).transfer(address(this).balance);
    }
