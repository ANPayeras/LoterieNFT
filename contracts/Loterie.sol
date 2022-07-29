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

}

contract mainERC721 is ERC721 {

    constructor() ERC721("Loterie", "LOT Ticket") {}
}