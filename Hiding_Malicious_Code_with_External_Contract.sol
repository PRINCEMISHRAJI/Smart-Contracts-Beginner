//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/*  Author: Ankit Mishra
    Let's say Alice can see the code of Foo and Bar but not Mali.
    It is obvious to Alice that Foo.callBar() executes the code inside Bar.log().
    However Eve deploys Foo with the address of Mali, so that calling Foo.callBar()
    will actually execute the code at Mali.
    */

    /*
    1. Eve deploys Mali
    2. Eve deploys Foo with the address of Mali
    3. Alice calls Foo.callBar() after reading the code and judging that it is
    safe to call.
    4. Although Alice expected Bar.log() to be execute, Mali.log() was executed.
*/

contract Foo{
    Bar bar;

    constructor(address _bar){
        bar = Bar(_bar);
    }

    function callBar() public{
        bar.log();
    }
}

contract Bar{
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}


// This code is hidden in separate file
contract Mali{ 
    event Log(string message);
    // function () external {
    //     emit Log("Mali was called");
    // }

    // Actually we can execute the same exploit even if this function does
    // not exist by using the fallback
    function log() public{
        emit Log("Mali was called");
    }
 }


 /*
    Preventative Techniques
        Initialize a new contract inside the constructor
        Make the address of external contract public so that the code of the external contract can be reviewed

    Bar public bar;
    constructor() public {
        bar = new Bar();
    }
*/