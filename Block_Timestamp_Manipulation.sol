//SPDX-License-Identifier: UNLICENSED

/*
Roulette is a game where you can win all of the Ether in the contract
if you can submit a transaction at a specific timing.
A player needs to send 10 Ether and wins if the block.timestamp % 15 == 0.
*/

/*
1. Deploy Roulette with 10 Ether
2. Chutki runs a powerful miner that can manipulate the block timestamp.
3. Chutki sets the block.timestamp to a number in the future that is divisible by
   15 and finds the target block hash.
4. Chutki's block is successfully included into the chain, Chutki wins the
   Roulette game.
*/


pragma solidity ^0.8.0;

contract Roulette{
    uint public pastBlockTime;

    constructor() payable{}

    function spin() external payable{
        require(msg.value == 10 ether); // must send 10 ether to play the roulette
        require(block.timestamp != pastBlockTime);  // only 1 transaction per block

        pastBlockTime = block.timestamp;

        if(block.timestamp %15 ==0 ){
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, " Failed to send transaction");
        }

    }
}   

/*
        Vulnerability
    block.timestamp can be manipulated by miners with the following constraints

    it cannot be stamped with an earlier time than its parent
    it cannot be too far in the future


*/