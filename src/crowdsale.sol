// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ntoken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdsale is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    // Variables
    Ntoken token; // ERC20 token contract
    address payable public wallet; // Address to receive Ether
    uint256 public rate; // Number of tokens per Ether
    uint256 public startTime; // Crowdsale start time
    uint256 public endTime; // Crowdsale end time
    uint256 public cliffDuration; // Duration before vesting starts
    uint256 public vestingDuration; // Duration of the vesting period
    bool public saleActive; // Flag to indicate if sale is active
    mapping(address => uint256) public investedAmount; // Amount of Ether invested by each participant
    mapping(address => uint256) public claimedTokens; // Amount of tokens claimed by each participant
    mapping(address => uint256) public PurchasedTokens; // Amount of tokens purchased by each participant

    // Events
    event SaleHalted(uint256 atTime);
    event SaleResumed(uint256 atTime);
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 tokens);
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    // Constructor
    constructor(
        Ntoken _token,
        address payable _wallet,
        uint256 _rate,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _cliffDuration,
        uint256 _vestingDuration
    ) {
        require(_startTime >= block.timestamp, "Start time should be in the future");
        require(_endTime > _startTime, "End time should be after start time");
        require(_rate > 0, "Rate should be greater than zero");
        require(_wallet != address(0), "Invalid wallet address");
        require(_endTime > _startTime, "End time must be after start time");
        require(_cliffDuration <= _vestingDuration, "Cliff duration must be less than or equal to vesting duration");

        token = _token;
        wallet = _wallet;
        rate = _rate;
        startTime = _startTime;
        endTime = _endTime;
        saleActive = false;
        cliffDuration = _cliffDuration;
        vestingDuration = _vestingDuration;
    }

    // Modifier to ensure the crowdsale is active
    modifier onlyWhileOpen() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Crowdsale not active");
        _;
    }

    // Modifier to ensure that tokens are claimed after the cliff duration
    modifier onlyAfterCliff() {
        require(block.timestamp >= startTime.add(cliffDuration), "Cliff period not reached");
        _;
    }

    // Modifier to ensure that the crowdsale is active and within specified time
    modifier onlySaleActive() {
        require(saleActive, "Crowdsale is not active");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Crowdsale is not within the specified time");
        _;
    }

    // Function to start the sale
    function startSale() onlyOwner external {
        require(block.timestamp >= startTime, "Sale has not started yet");
        saleActive = true;
    }

    // Function to halt the sale
    function haltSale() onlyOwner external {
        require(saleActive, "Sale is not active");
        saleActive = false;
        emit SaleHalted(block.timestamp);
    }

    // Function to resume the sale
    function resumeSale() onlyOwner external {
        require(!saleActive, "Sale is already active");
        require(block.timestamp < endTime, "Crowdsale end date has passed");
        saleActive = true;
        emit SaleResumed(block.timestamp);
    }

    // Function to buy tokens
    function buyTokens() public payable onlyWhileOpen onlySaleActive nonReentrant {
        uint256 amount = msg.value;
        uint256 tokens = amount.mul(rate);
        investedAmount[msg.sender] = investedAmount[msg.sender].add(amount);
        PurchasedTokens[msg.sender] = PurchasedTokens[msg.sender].add(tokens);
        emit TokensPurchased(msg.sender, amount, tokens);
    }

    // Function to claim vested tokens
    function claimTokens(uint256 tokenstoClaim) public onlyAfterCliff nonReentrant{
        require(claimedTokens[msg.sender] < PurchasedTokens[msg.sender], "Already claimed all tokens");
        uint256 totalTokens = PurchasedTokens[msg.sender];
        uint256 vestedTokens = totalVestedAmount(totalTokens).sub(claimedTokens[msg.sender]);
        require(vestedTokens >= tokenstoClaim, "No tokens to claim");
        claimedTokens[msg.sender] = claimedTokens[msg.sender].add(tokenstoClaim);
        token.transfer(msg.sender, tokenstoClaim);
        emit TokensClaimed(msg.sender, tokenstoClaim);
    }

    // Function to calculate vested amount based on vesting schedule
    function totalVestedAmount(uint256 totalTokens) public view returns (uint256) {
        if (block.timestamp < startTime.add(cliffDuration)) {
            return 0;
        }
        uint256 timeSinceStart = block.timestamp.sub(startTime).sub(cliffDuration);
        if (timeSinceStart >= vestingDuration) {
            return totalTokens;
        }
        return totalTokens.mul(timeSinceStart).div(vestingDuration);
    }

    // Function to withdraw Ether from the contract
    function withdrawEther() public nonReentrant{
        require(msg.sender == wallet, "Only wallet can withdraw Ether");
        wallet.transfer(address(this).balance);
    }

   
    // Function to check if a participant has claimed all their tokens
    function tokensClaimed(address beneficiary) public view returns (bool) {
        return claimedTokens[beneficiary] >= PurchasedTokens[beneficiary];
    }

    
}
