pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPEthToken is Ownable, ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function init(uint256 tokens) public payable returns (uint256) {
        require(
            lpEthToken.totalSupply() == 0,
            "DEX:init - already has liquidity"
        );
        lpEthToken.mint(msg.sender, address(this).balance);

        require(token.transferFrom(msg.sender, address(this), tokens));
        return lpEthToken.totalSupply();
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}
