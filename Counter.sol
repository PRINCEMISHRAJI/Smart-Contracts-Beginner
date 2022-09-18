//SPDX-License-Identifier: Unlicensed

/* This is a basic Counter contract 
    constructor takes the name and count upon Deployment
    increments the counter number by 1 (Requires Gas Fee)
    decrements counter by 1 (Requires Gas Fee)
    Shows Name  (No Gas fee required)
    Shows Count (No Gas fee required)
    Updates Name (Requires Gas Fee)*/

pragma solidity ^0.8.0;

contract Counter{
    uint32 public count;
    string public name;

    constructor(string memory _name, uint32 _initialCount) {
        name = _name;
        count = _initialCount;
    }

    function increment() public returns(uint32 newCount) {
        count ++;
        return count;
    }

    function decrement() public returns(uint32 newCount){
        count --;
        return count;
    }    

    function getCount() public view returns(uint32) {
        return count;
    }

    function getName() public view returns (string memory){
        return name;
    }

    function setName(string memory _newName) public returns(string memory){
        name = _newName;
        return name;
    }
}