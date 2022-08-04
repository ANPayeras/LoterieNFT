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
    function register() internal {
        address personal_contract_address = address(new ticketsNFTs(msg.sender, address(this), nft));
        user_contract[msg.sender] = personal_contract_address;
    }

    // Info from an User
    function userInfo(address _account) public view returns (address) {
        return user_contract[_account];
    }

    // Buy Tokens ERC-20
    function buyTokens(uint256 _numTokens) public payable {
        // Register user if never buy
        if(user_contract[msg.sender] == address(0)) {
            register();
        } 
        uint256 tokenCost = tokenPrice(_numTokens);
        require(msg.value >= tokenCost, "You don't have enough ethers to buy the tokens");
        uint256 returnValue = msg.value - tokenCost;
        // Return tokens if is necessary
        payable(msg.sender).transfer(returnValue);
        _transfer(address(this), msg.sender, _numTokens);
    }

    // Cashback Tokens to Smart Contract
    function cashBackTokens(uint _numTokens) public payable {
        require(_numTokens >= 0, "The amount must be greater than 0");
        require(_numTokens <= tokenBalance(msg.sender), "You don't have the tokens to cashback");
        // The user send the tokens to the Smart Contract
        _transfer(msg.sender, address(this), _numTokens);
        // The Smart Contract send the ethers to the user
        payable(msg.sender).transfer(tokenPrice(_numTokens));
    }

    // Loterie managment
    // Ticket price in tokens (ERC-20)
    uint public ticketPrice = 5;
    mapping(address => uint []) user_tickets;
    mapping(uint => address) ADNTicket;
    uint randomNumber = 0;
    uint [] buyedTickets;

    function buyTicket(uint _numTickets) public {
        uint totalPrice = _numTickets * ticketPrice;
        require(totalPrice <= tokenBalance(msg.sender), "You don't have enough tokens");
        // Send tokens to the Smart Contract
        _transfer(msg.sender, address(this), totalPrice);

        for (uint i = 0; i < _numTickets; i++) {
            // Aleatory number between 0 - 9999
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomNumber))) % 10000;
            randomNumber++;
            user_tickets[msg.sender].push(random);
            buyedTickets.push(random);
            ADNTicket[random] = msg.sender;
            // Create a new NFT for a ticket
            ticketsNFTs(user_contract[msg.sender]).mintTicket(msg.sender, random);
        }
    }

    function myTickets(address _owner) public view returns(uint [] memory) {
        return user_tickets[_owner];
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