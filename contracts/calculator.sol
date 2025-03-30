// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Calculator {
    uint public result;
    address public owner;

    event CalculationPerformed(string operation, uint operand1, uint operand2, uint result);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        result = 0;
    }

    function add(uint num1, uint num2) public onlyOwner returns (uint) {
        result = num1 + num2;
        emit CalculationPerformed("Adding", num1, num2, result);
        return result;
    }

    function sub(uint num1, uint num2) public onlyOwner returns (uint) {
        require(num2 <= num1, "Result will be negative");
        result = num1 - num2;
        emit CalculationPerformed("Subtraction", num1, num2, result);
        return result;
    }

    function multi(uint num1, uint num2) public onlyOwner returns (uint) {
        result = num1 * num2;
        emit CalculationPerformed("Multiplication", num1, num2, result);
        return result;
    }

    function div(uint num1, uint num2) public onlyOwner returns (uint) {
        require(num2 > 0, "Division by 0");
        result = num1 / num2;
        emit CalculationPerformed("Division", num1, num2, result);
        return result;
    }
}
