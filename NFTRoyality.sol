// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract NFTroyality is ERC1155, IERC2981, Ownable, Pausable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string internal _uriBase;
    string public name;
    string public symbol;
    uint256 public cost = 0.05 ether;
    uint256 public total_supply;
    address private _recipient;
    uint256 public _editionLimit;

    mapping (address => uint256) public Tokeninfo;

    constructor() ERC1155("https://token-cdn-domain/{id}.json") {

        name = "Pluton";
        symbol = "PL"; 
        total_supply = 14;
        _editionLimit = 10;
        _recipient = owner();

    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(uint256 id, uint256 amount) public payable {
        require(msg.value >= cost, "Insufficient Balance");
        _tokenIdCounter.increment();
        _mint(msg.sender, id, amount,"");
        Tokeninfo[msg.sender] = id;
    }


    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }


    function uri(uint256 tokenId) override public view returns (string memory) {
        require(tokenId >= 1 && tokenId <= total_supply, "ERC1155Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_uriBase, Strings.toString(tokenId), ".json"));
    }

    function _setRoyalties(address newRecipient) internal {
        require(newRecipient != address(0), "Royalties: new recipient is the zero address");
        _recipient = newRecipient;
    }

    function setRoyalties(address newRecipient) external onlyOwner {
        _setRoyalties(newRecipient);
    }


    function royaltyInfo(uint256 tokenId, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        return (_recipient, (_salePrice * 1000) / 10000);
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, IERC165)
        returns (bool)
    {
        return (
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId)
        );
    }

    
  
    function contractURI() public pure returns (string memory) {
        return "ipfs://bafkreigpykz4r3z37nw7bfqh7wvly4ann7woll3eg5256d2i5huc5wrrdq"; 
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Zero Balance");
        payable(_recipient).transfer(address(this).balance);
    }
}