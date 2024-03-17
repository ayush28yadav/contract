// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ntoken {
    // Variables
    string public name = "Ntoken"; // Name of the token
    string public symbol = "NTK"; // Symbol of the token
    uint8 public decimals = 18; // Number of decimal places for the token
    uint256 public totalSupply; // Total supply of the token

    // Mapping to store token balances of addresses
    mapping(address => uint256) public balanceOf;

    // Mapping to store allowed amounts for spenders
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value); // Event emitted when tokens are transferred
    event Approval(address indexed owner, address indexed spender, uint256 value); // Event emitted when an allowance is set

    // Constructor to initialize the total supply and assign it to the deployer's address
    constructor() {
        totalSupply = 1000000 * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    // Function to transfer tokens from the caller's address to another address
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance"); 
        _transfer(msg.sender, _to, _value); 
        return true;
    }

    // Internal function to perform the token transfer and emit the Transfer event
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid recipient address"); 
        balanceOf[_from] -= _value; 
        balanceOf[_to] += _value; 
        emit Transfer(_from, _to, _value); 
    }

    // Function to approve a spender to spend a certain amount of tokens on behalf of the caller
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid spender address");
        allowance[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value); 
        return true;
    }

    // Function to transfer tokens from one address to another, requiring approval from the owner
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance"); 
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance"); 
        _transfer(_from, _to, _value); 
        return true;
    }
}