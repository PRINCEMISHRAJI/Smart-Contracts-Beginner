//SPDX-License-Identifier: UNLICENSED

/*  Author: Ankit Mishra
    This is a minimal example of a contract that rewards users for staking their token.
    Staking is used to incentivize users
    Staking locks up your assets to participate and help maintain the security of that network's blockchain.
    In exchange for locking up your assets and participating in the network validation, validators receive rewards in that cryptocurrency. 
*/

pragma solidity ^0.8.0;


contract StakingRewards{
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    address public owner;

    //Duration of rewards to be paid out(in seconds)
    uint public duration;

    //Timestamp of when the rewards finish
    uint public finishAt;

    //Minimum of last updated time and finish time
    uint public updatedAt;

    //Reward to be paid out per seconds
    uint public rewardRate;

    //  Sum of (rewardRate * dt * 1e18 / totalSupply)
    uint public rewardPerTokenStored;

    // User address => rewardPerTokenStored
    mapping(address => uint ) public userRewardPerTokenPaid;

    //User address => rewards to be claimed
    mapping(address => uint) public rewards;

    //Total staked
    uint public totalSupply;
    // user address => staked amount
    mapping(address => uint) public balanceOf;

    constructor(address _stakingToken, address _rewardToken){
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not Authorized");
        _;
    }

    modifier updateReward(address _account){
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if(_account != address(0)){
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns(uint){
        return _min(finishAt, block.timestamp);
    }

    function rewardPerToken() public view returns(uint) {
        if(totalSupply == 0)
            return rewardPerTokenStored;
        else
            return rewardPerTokenStored + ( rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) / totalSupply;
    }

    function stake(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, " amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function withdraw(uint _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount =0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function earned(address _account) public view returns(uint) {
        return ((balanceOf[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) + rewards[_account];
    }

    function getReward() external updateReward(msg.sender){
        uint reward = rewards[msg.sender];
        if(reward > 0){
            rewards[msg.sender] =0;
            rewardToken.transfer(msg.sender, reward);
        }
    }   

    function setRewardsDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward Duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount) external onlyOwner updateReward(address(0)) {
        if(block.timestamp >= finishAt)
            rewardRate = _amount/ duration;
        else{
            uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount * remainingRewards) / duration;
        }

        require(rewardRate > 0, " reward rate =0");
        require(rewardRate * duration <= rewardToken.balanceOf(address(this)), "reward amount > balance");
         finishAt = block.timestamp + duration;
         updatedAt = block.timestamp;
    }

    function _min(uint x, uint y) private pure returns(uint){
        return x <= y ? x : y;
    }
}

interface IERC20{
    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient, uint amount) external returns(bool);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

}