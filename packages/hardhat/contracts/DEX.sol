pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT
// import "hardhat/console.sol";

import "./LPEthToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    IERC20 token;
    LPEthToken public lpEthToken; //<---Define token variable

    //Add this events definitions
    event EthToTokenSwap(
        address swapper,
        string txDetails,
        uint256 ehtInput,
        uint256 tokenOutput
    );
    event TokenToEthSwap(
        address swapper,
        string txDetails,
        uint256 tokenInput,
        uint256 ehtOutput
    );
    event LiquidityProvided(
        address liquidityProvider,
        uint256 tokenInput,
        uint256 ethInput,
        uint256 liquidityMinted
    );
    event LiquidityRemoved(
        address liquidityRemover,
        uint256 tokenOutput,
        uint256 ethOutput,
        uint256 liquidityBurned
    );

    constructor(address token_addr) {
        token = IERC20(token_addr);
        lpEthToken = new LPEthToken("LPEthToken", "LPDEX"); //<---Deploy contract and set token varible
    }

    function init(uint256 tokens) public payable returns (uint256) {
        require(
            lpEthToken.totalSupply() == 0,
            "DEX:init - already has liquidity"
        );
        lpEthToken.mint(msg.sender, address(this).balance);

        require(token.transferFrom(msg.sender, address(this), tokens));
        return lpEthToken.totalSupply();
    }
}
