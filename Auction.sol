// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Auction {
    address public owner;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    bool public auctionEnded;

    mapping(address => uint) public bids;

    event NewBid(address bidder, uint amount);

    event AuctionEnded(address winner, uint amount);

    constructor(uint _durationMinutes) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyBeforeEnd() {
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function bid() public payable onlyBeforeEnd {
        require(msg.value > highestBid, "Bid amount is too low");

        if (highestBidder != address(0)) {
            // Refund the previous highest bidder
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit NewBid(msg.sender, msg.value);
    }

    function endAuction() public onlyOwner {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!auctionEnded, "Auction has already ended");

        auctionEnded = true;
        if (highestBidder != address(0)) {
            payable(owner).transfer(highestBid);
            emit AuctionEnded(highestBidder, highestBid);
        }
    }

    function withdraw() public {
        require(auctionEnded || block.timestamp >= auctionEndTime, "Auction is still ongoing");

        uint amount = bids[msg.sender];
        require(amount > 0, "You have no funds to withdraw");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

