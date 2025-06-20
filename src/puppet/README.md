# Puppet

There’s a lending pool where users can borrow Damn Valuable Tokens (DVTs). To do so, they first need to deposit twice the borrow amount in ETH as collateral. The pool currently has 100_000 DVTs in liquidity.

There’s a DVT market opened in an old Uniswap v1 exchange, currently with 10 ETH and 10 DVT in liquidity.

Pass the challenge by saving all tokens from the lending pool, then depositing them into the designated recovery account. You start with 25 ETH and 1000 DVTs in balance. 


## Answer

The solution is easy, you buy most of the eth with all your DVT you have almost draining the UNIswap pool of eth (dust remianing) and then you can borrow 100_000 DVT tokens with 20 eth of collateral aprox, then send the DVTs to the recovery account. I need to do all of this in one transaction so the idea is to create a another contract and transfer them all the funds to make the attack. For the DVT tokens need to make a permit function and then when I deploy the new contract execute the whole iteration of the  attack in the constructor.