// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract toSuiBridge is Ownable {

    uint64 sequence_ = 0;
    // Bridge event
    event Bridge(address indexed user, uint64 orderId,uint256 amount, address to);
    event FinishOrderEvent(uint64 indexed orderId, address to, uint256 amount);

    event Withdrawal(address indexed user, uint256 amount);


    constructor() Ownable(msg.sender) {}

    /**
     * 
     * @param to Sui account address
     */
    function bridge(address to) public payable {
        uint64 orderId = genOrderId(sequence_++);
        require(msg.value > 0);
        require(to!= address(0));
        emit Bridge(msg.sender, orderId,  msg.value, to);
    }

    function withdrawal() public onlyOwner {
        emit Withdrawal(msg.sender, address(this).balance);

        payable(owner()).transfer(address(this).balance);
    }

    function mint(uint64 orderId, uint256 amount, address to) external payable onlyOwner {
        require(address(this).balance >= amount) ;
        payable(to).transfer(amount);
        emit FinishOrderEvent(orderId, to, amount);
    }

    function genOrderId(uint64 sequence) public view returns (uint64) {
        uint64 unix = uint64(block.timestamp * 1000); // 获取时间戳并转换为毫秒
        uint64 random = (unix + sequence) % 1000000; // 计算随机数
        uint64 orderId = (unix << 6) + random; // 生成订单ID
        return orderId;
    }
}
