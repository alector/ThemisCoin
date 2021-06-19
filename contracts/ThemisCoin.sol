//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ThemisCoin is ERC20, Ownable, Pausable {
    constructor(address owner_, uint256 totalSupply_) ERC20("Themis Coin", "TMC") {
        Ownable.transferOwnership(owner_);
        ERC20._mint(owner_, totalSupply_ * 10**decimals());
    }

    function mint(uint256 amount) public onlyOwner whenNotPaused {
        ERC20._mint(Ownable.owner(), amount);
    }

    function burn(address account, uint256 amount) public onlyOwner whenNotPaused {
        ERC20._burn(account, amount);
    }

    function pause() public onlyOwner whenNotPaused {
        Pausable._pause();
    }

    function unpause() public onlyOwner whenPaused {
        Pausable._unpause();
    }

    // IMPORTANT NOTICE
    // THE FOLLOWING FUNTIONS ALREADY AVAILABLE
    // THROUGH INHERITANCE FROM ERC20

    // function getOwner() public view returns (address) {
    //     return Ownable.owner();
    // }

    // function getTotalSupply() public view returns (uint256) {
    //     return ERC20.totalSupply();
    // }

    // function getBalanceOf(address account) public view returns (uint256) {
    //     return ERC20.balanceOf(account);
    // }

    // function getAllowance(address owner, address spender) public view returns (uint256) {
    //     return ERC20.allowance(owner, spender);
    // }
}
