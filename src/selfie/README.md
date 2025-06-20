# Selfie

A new lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.

What could go wrong, right ?

You start with no DVT tokens in balance, and the pool has 1.5 million at risk.

Rescue all funds from the pool and deposit them into the designated recovery account.

## Answer

Pretty easy, when you see that having more than a half of the totalSupply of the voting token it enables you to execute the function `emergencyExit()` just by receiving the flahloan (gets you more than half of totalSupply) then creating the action to drain the contract and then after two days execute the action effectively ¡ draining the whole contract.
