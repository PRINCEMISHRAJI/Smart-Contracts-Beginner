// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract MyContract{
    uint8 public peopleCount =0;
    mapping(uint => Person) public people;
    uint32 openingTime = 1663440700;
    modifier onlyWhileOpen(){
        require(block.timestamp >= openingTime);
        _;
    }


    struct Person{
        uint _id;
        string _firstName;
        string _lastName;
    }


    function addPerson( string memory _firstName, string memory _lastName) public onlyWhileOpen {
        incrementCount();
        people[peopleCount] = Person(peopleCount, _firstName, _lastName);
    }

    function incrementCount() internal{
        peopleCount += 1;
    }
}