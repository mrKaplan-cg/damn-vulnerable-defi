# Truster

More and more lending pools are offering flashloans. In this case, a new pool has launched that is offering flashloans of DVT tokens for free.

The pool holds 1 million DVT tokens. You have nothing.

To pass this challenge, rescue all funds in the pool executing a single transaction. Deposit the funds into the designated recovery account.

## Answer:
Easy, when doing the flashloan it will call any function from `target` address. As you can control the target address, you can do the following:

- Make a minimal flashloan.
- Setting the target address as DVT token address.
- Setting the data field as `abi.encodeWithSignature("approve(address,uint256)", address(targetAddress), type(uint256).max);`
- This settings will cause that the truster contract will approve you to spend his funds on his behalf.
- Drains the entire contract. 
