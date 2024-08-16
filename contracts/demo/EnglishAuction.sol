// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _nftId) external;
}

/// @title 英式拍卖
/// @author zhanghony
/// @notice 介绍英式拍卖及其基本机制
/// @dev 模拟出价过程,检查拍卖状态,进⾏资⾦提取
contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address highestBidder, uint256 highestBid);
    IERC721 public immutable nft;
    uint256 public immutable nftId;
    address payable public immutable seller;
    uint32 public endAt;
    bool public started;
    bool public ended;
    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public bids;

    /// @notice 初始化合约状态变量
    /// @dev Explain to a developer any extra details
    /// @param _nft 设置NFT合约地址
    /// @param _nftId 设置NFTid
    /// @param _startingBid 设置起始出价⾦额
    /// @dev 设置卖家地址为部署合约者
    constructor(address _nft, uint256 _nftId, uint256 _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    /// @notice 开始拍卖
    /// @dev 转移NFT所有权⾄合约,触发拍卖开始事件
    function start() external {
        require(msg.sender == seller, "not seller");
        require(!started, "started");
        started = true;
        endAt = uint32(block.timestamp + 60);
        nft.transferFrom(seller, address(this), nftId);
        emit Start();
    }

    /// @notice 接受出价
    /// @dev 确认拍卖已开始且未结束,确认出价⾼于当前最⾼出价,更新最⾼出价和最⾼出价⼈,记录⾮最⾼出价⼈的出价,触发出价事件
    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest bid");
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }

    /// @notice 允许⾮最⾼出价⼈提取其出价⾦额
    /// @dev 保护合约免受重⼊攻击
    function withdraw() external {
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        emit Withdraw(msg.sender, bal);
    }

    /// @notice 结束拍卖
    /// @dev 转移NFT所有权⾄最⾼出价⼈,将最⾼出价⾦额转移给卖家,处理⽆⼈出价的情况,触发拍卖结束事件
    function end() external {
        require(started, "not started");
        require(!ended, "ended");
        require(block.timestamp >= endAt, "not ended");
        ended = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }
        emit End(highestBidder, highestBid);
    }
}
