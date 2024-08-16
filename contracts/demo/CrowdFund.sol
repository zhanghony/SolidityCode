// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// // import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


// /// @title 基于ERC20代币创建众筹合约
// /// @author zhagnhony
// /// @notice 掌握如何使⽤Solidity0.8开发众筹合约
// /// @dev 创建众筹活动,取消众筹活动,⽀持者参与和取消参与众筹,领取众筹成功的代币,退款失败的众筹代币
// contract CrowdFund {
//     struct Campaign {
//         /// @notice 众筹创建者的地址
//         address creator;
//         /// @notice 众筹⽬标⾦额
//         uint256 goal;
//         /// @notice 众筹开始时间
//         uint32 startAt;
//         /// @notice 众筹结束时间
//         uint32 endAt;
//         /// @notice 是否已领取众筹代币
//         bool claimed;
//         /// @notice 已筹集的代币数量
//         uint256 pledged;
//     }
//     /// @notice 众筹使⽤的ERC20代币
//     IERC20 public immutable token;
//     /// @notice 存储众筹活动
//     mapping(uint256 => Campaign) public campaigns;
//     /// @notice 众筹活动计数器
//     uint256 public count;
//     /// @notice ⽤⼾在特定众筹活动中的出资记录
//     mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

//     /// 构造函数
//     /// @param _token 初始化代币地址
//     constructor(address _token) {
//         token = IERC20(_token);
//     }

//     /// @notice ⽤⼾参与众筹，出资代币
//     /// @dev 验证活动已开始且未结束
//     /// @param _id a parameter just like in doxygen (must be followed by parameter name)
//     /// @param _amount a parameter just like in doxygen (must be followed by parameter name)
//     /// @return Documents the return variables of a contract’s function state variable
//     /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
//     function pledge(uint256 _id, uint256 _amount) external {
//         Campaign storage campaign = campaigns[_id];
//         require(block.timestamp >= campaign.startAt, "Campaign not started");
//         require(block.timestamp <= campaign.endAt, "Campaign ended");
//         campaign.pledged += _amount;
//         pledgedAmount[_id][msg.sender] += _amount;
//         token.transferFrom(msg.sender, address(this), _amount);
//     }

//     /// @notice ⽤⼾取消参与众筹，退还出资的代币
//     /// @dev 验证活动未结束
//     /// @param _id a parameter just like in doxygen (must be followed by parameter name)
//     /// @param _amount a parameter just like in doxygen (must be followed by parameter name)
//     /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
//     function unpledge(uint256 _id, uint256 _amount) external {
//         Campaign storage campaign = campaigns[_id];
//         require(block.timestamp <= campaign.endAt, "Campaign ended");
//         campaign.pledged -= _amount;
//         pledgedAmount[_id][msg.sender] -= _amount;
//         token.transfer(msg.sender, _amount);
//     }
// }
