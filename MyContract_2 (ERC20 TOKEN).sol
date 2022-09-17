// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ERC20Token{
    string public Name;
    mapping(address => uint256) public balances;
    function mint() public{
        balances[tx.origin] ++;
    }
}

contract MyContract{
    address payable wallet;
    address public token;
    constructor(address payable _wallet, address _token) {
        wallet = _wallet;  
        token = _token;
    }   

    fallback() external payable{
        buyToken();
    }

    function buyToken() public payable{
        ERC20Token(address(token))mint();
        wallet.transfer(msg.value);
    }


}
