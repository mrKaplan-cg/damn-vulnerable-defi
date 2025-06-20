# Unstoppable

There's a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To catch any bugs before going 100% permissionless, the developers decided to run a live beta in testnet. There's a monitoring contract to check liveness of the flashloan feature.

Starting with 10 DVT tokens in balance, show that it's possible to halt the vault. It must stop offering flash loans.


## Answer:

Easy, donate some funds to the vault, and then as is using wrong the `convertToShares()` (should use `convertToAssets(totalSupply)`), then this line:
`if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement`.
 
Will always revert as we disproportiante the amounts by donating some funds. Full DoS.