// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

library Math{
    function divide(uint256 a, uint256 b) internal pure returns(uint256){
        require(b >0);
        uint256 c = a/b;
        return c;
    }
}

contract MyContract{
    uint256 public value;

    function calculate(uint256 _value1, uint256 _value2) public{
        value = Math.divide(_value1, _value2);  
    }
}