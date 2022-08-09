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

    function yAmo(
        uint256 xAmo,
        uint256 xRes,
        uint256 yRes
    ) public pure returns (uint256) {
        return (xAmo * 997 * yRes) / (xRes * 1000 + xAmo * 997);
    }

    function ethToToken() public payable returns (uint256) {
        require(msg.value > 0, "cannot swap 0 ETH");
        //Reserve calculation
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        //Trade execution
        uint256 tokensBought = yAmo(msg.value, ethReserve, tokenReserve);
        require(
            token.transfer(msg.sender, tokensBought),
            "ethToToken(): reverted swap."
        );
        emit EthToTokenSwap(
            msg.sender,
            "Eth to Ballons",
            msg.value,
            tokensBought
        );
        return tokensBought;
    }

    function tokenToEth(uint256 tokens) public returns (uint256) {
        require(tokens > 0, "cannot swap 0 tokens");
        //Reserve calculation
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        //Trade execution
        uint256 ethBought = yAmo(tokens, tokenReserve, ethReserve);
        (bool sent, ) = msg.sender.call{value: ethBought}("");
        require(sent, "tokenToEth(): failed to send user eth.");
        require(
            token.transferFrom(msg.sender, address(this), tokens),
            "tokenToEth(): reverted swap."
        );
        emit TokenToEthSwap(msg.sender, "Ballons to ETH", ethBought, tokens);
        return ethBought;
    }

    function deposit() public payable returns (uint256) {
        //Reserve calculation
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        //Liquidity deposit
        uint256 tokenAmount = (msg.value * tokenReserve) / ethReserve;
        require(token.transferFrom(msg.sender, address(this), tokenAmount));
        //share token minting
        uint256 liquidityMinted = (msg.value * lpEthToken.totalSupply()) /
            ethReserve;
        lpEthToken.mint(msg.sender, liquidityMinted);
        emit LiquidityProvided(
            msg.sender,
            liquidityMinted,
            msg.value,
            tokenAmount
        );
        return liquidityMinted;
    }

    function withdraw(uint256 liqAmount) public returns (uint256, uint256) {
        //Reserve calculation
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 totaLiq = lpEthToken.totalSupply();
        //Liquidity withdraw
        uint256 tokenAmount = (tokenReserve * liqAmount) / totaLiq;
        uint256 ethAmount = (ethReserve * liqAmount) / totaLiq;
        require(token.transfer(msg.sender, tokenAmount));
        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        require(sent, "Failed to send user eth.");
        //share token burning
        lpEthToken.burn(msg.sender, liqAmount);
        emit LiquidityRemoved(msg.sender, liqAmount, ethAmount, tokenAmount);
        return (tokenAmount, ethAmount);
    }
}
