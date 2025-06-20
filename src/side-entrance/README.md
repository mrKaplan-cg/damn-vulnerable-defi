# Side Entrance

A surprisingly simple pool allows anyone to deposit ETH, and withdraw it at any point in time.

It has 1000 ETH in balance already, and is offering free flashloans using the deposited ETH to promote their system.

You start with 1 ETH in balance. Pass the challenge by rescuing all ETH from the pool and depositing it in the designated recovery account.


## Answer:

THe flashloan function is only cheking that the current balance is equal to the before balance, you can take that balance from the flashloan, deposit through the pool, this will increase the balance mapping of your account, and then you can withdraw that same amount to your account, draining the contract entirely.
