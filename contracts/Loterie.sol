// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";

contract Loterie is ERC20, Ownable {

    address public nft;

    constructor() ERC20("Loterie Token", "LOT") {
        _mint(address(this), 1000);
        nft = address(new mainERC721());
    }

    address public winner;

    mapping(address => address) public user_contract;

    // Token Price
    function tokenPrice(uint256 _numTokens) internal pure returns (uint256) {
        return _numTokens * (1 ether);
    }

    // Address's ERC-20 Balance
    function tokenBalance(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    // Smart Contract Balance
    function tokenBalanceSC() public view returns (uint256) {
        return balanceOf(address(this));
    }

    // Ethers Balance
    function ethersBalance() public view returns (uint256) {
        return address(this).balance / 10**18;
    }

    // New Tokens ERC-20 Issue
    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // Users Registrer
    function registrar() internal {
        address personal_contract_address = address(new ticketsNFTs(msg.sender, address(this), nft));
        user_contract[msg.sender] = personal_contract_address;
    }

    // Info from an User
    function userInfo(address _account) public view returns (address) {
        return user_contract[_account];
    }

}

contract mainERC721 is ERC721 {

    address public loterieAddress;

    constructor() ERC721("Loterie", "LOT Ticket") {
        // This contract is deployed automatically by the Loterie contract
        loterieAddress = msg.sender;
    }

    // NFT Creation
    function safeMint(address _owner, uint256 _ticket) public {
        require(msg.sender == Loterie(loterieAddress).userInfo(_owner), "You don't have access to execute this function");
        _safeMint(_owner, _ticket);
    }

}

contract ticketsNFTs {

    struct Owner {
        address ownerAddress;
        address loterieAddress;
        address nftContract;
        address userContract;
    }

    Owner public owner;

    constructor(address _owner, address _loterieAddress, address _nftContract) {
        owner = Owner(_owner, _loterieAddress, _nftContract, address(this));
    }

    function mintTicket(address _owner, uint _ticket) public {
        require(msg.sender == owner.loterieAddress, "You don't have access to execute this function");
        mainERC721(owner.nftContract).safeMint(_owner, _ticket);
    }

}