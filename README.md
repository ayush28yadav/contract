
This repository contains two Solidity smart contracts:

Ntoken.sol: An ERC-20 compliant token contract.
Crowdsale.sol: A crowdsale contract with vesting and cliff period features.



Ntoken.sol
The Ntoken.sol contract is an implementation of the ERC-20 standard for creating a custom token called "Ntoken" with the symbol "NTK". It defines the total supply of tokens, manages token balances, and provides functions for transferring tokens between addresses.

Contract Details
Token Name: Ntoken
Token Symbol: NTK
Decimal Places: 18
Total Supply: 1,000,000 tokens
Functions
constructor(): Initializes the total supply of tokens and assigns them to the deployer's address.
transfer(address _to, uint256 _value): Transfers _value tokens from the caller's address to the _to address.
approve(address _spender, uint256 _value): Approves a _spender address to spend _value tokens on behalf of the caller.
transferFrom(address _from, address _to, uint256 _value): Transfers _value tokens from the _from address to the _to address, if the caller has sufficient allowance.
Events
Transfer(address indexed from, address indexed to, uint256 value): Emitted when tokens are transferred from one address to another.
Approval(address indexed owner, address indexed spender, uint256 value): Emitted when an allowance is set for a spender.



Crowdsale.sol
The Crowdsale.sol contract is a crowdsale implementation that allows investors to purchase Ntoken tokens in exchange for Ether. It includes vesting and cliff period features, ensuring that the tokens are gradually released to investors over time.

Contract Details
Token Contract: Ntoken.sol
Wallet Address: Specified during deployment
Token Rate: Specified during deployment (e.g., 1000 tokens per Ether)
Start Time: Specified during deployment
End Time: Specified during deployment
Cliff Duration: Specified during deployment
Vesting Duration: Specified during deployment
Functions
startSale(): Starts the crowdsale if the start time has been reached (only callable by the owner).
haltSale(): Halts the crowdsale if it's active (only callable by the owner).
resumeSale(): Resumes the halted crowdsale if the end time hasn't passed (only callable by the owner).
buyTokens(): Allows investors to purchase tokens in exchange for Ether during the crowdsale active period.
claimTokens(uint256 tokenstoClaim): Allows investors to claim their vested tokens after the cliff duration.
withdrawEther(): Allows the contract owner to withdraw Ether from the contract (only callable by the wallet address).
tokensClaimed(address beneficiary): Checks if a participant has claimed all their tokens.
Events
SaleHalted(uint256 atTime): Emitted when the sale is halted.
SaleResumed(uint256 atTime): Emitted when the sale is resumed.
TokensPurchased(address indexed buyer, uint256 amount, uint256 tokens): Emitted when tokens are purchased.
TokensClaimed(address indexed beneficiary, uint256 amount): Emitted when tokens are claimed.



Deployment
to deploy these contracts set up your .env file with all the variable data needed and use these forge commands 


dotenv forge create src/Ntoken.sol:Ntoken --rpc-url $RPC_URL --private-key $PRIVATE_KEY

dotenv forge create src/Crowdsale.sol:Crowdsale --rpc-url $RPC_URL --private-key $PRIVATE_KEY


