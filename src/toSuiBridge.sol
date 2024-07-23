// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract toSuiBridge is Ownable {


    // Bridge event
    event Bridge(address indexed user, uint256 amount, address to);
    // Mint event
    event Mint(address indexed to, uint256 amount);

    event WithDrawl(address indexed user, uint256 amount);

    constructor() Ownable(msg.sender) {}

    /**
     * 
     * @param to Sui account address
     */
    function bridge(address to) public payable {
        require(msg.value > 0);
        emit Bridge(msg.sender, msg.value, to);
    }

    function withDrawl() public onlyOwner {
        emit WithDrawl(msg.sender, address(this).balance);

        payable(owner()).transfer(address(this).balance);
    }

    function mint(uint256 amount, address to) external payable onlyOwner {
        require(address(this).balance >= amount) ;
        payable(to).transfer(amount);
        emit Mint(to, amount);
    }
}
