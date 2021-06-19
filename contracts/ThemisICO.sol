//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "hardhat/console.sol";
import "./ThemisCoin.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ThemisICO is Ownable, Pausable {
    using Address for address payable;
    ThemisCoin private _coin;
    address private _ownerCoin;
    address private _coinAddress;

    constructor(address ownerICO_, address coinAddress_) {
        Ownable.transferOwnership(ownerICO_);
        _coinAddress = coinAddress_;
        _coin = ThemisCoin(_coinAddress);
    }

    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);
    event Faucet(address indexed recipient, uint256 amount);

    function setCoin(address coinAddress_) public onlyOwner {
        // TO DO: REQUIRE NO ZERO ADDRESS
        _coinAddress = coinAddress_;
        _coin = ThemisCoin(coinAddress_);
    }

    function getCoinOwner() public view returns (address) {
        return _coin.owner();
    }

    function getContractAllowance() public view returns (uint256) {
        return _coin.allowance(_coin.owner(), address(this));
    }

    function getCoinAddress() public view returns (address) {
        return _coinAddress;
    }

    function transferOwnershipICO(address newOwner) public onlyOwner {
        Ownable.transferOwnership(newOwner);
    }

    receive() external payable {
        _buyTokens(msg.sender, msg.value);
    }

    function buyTokens() public payable {
        _buyTokens(msg.sender, msg.value);
    }

    function _buyTokens(address sender, uint256 amount) private whenNotPaused {
        require(
            amount % 10**9 == 0,
            "THEMIS ICO: Contract doesn't give back change. The received amount must be divisible by price."
        );
        uint256 numTokens = amount * 10**9;
        _coin.transferFrom(_ownerCoin, sender, numTokens);
        emit Deposit(sender, amount);
    }

    function pause() public onlyOwner whenNotPaused {
        Pausable._pause();
    }

    function unpause() public onlyOwner whenPaused {
        Pausable._unpause();
    }

    function faucetCoin() public whenNotPaused {
        uint256 oneToken = 1000000000000000000;
        // a large amount of coints have to be previously approved to this contract's address
        // TODO: add time limit
        _coin.transferFrom(_coin.owner(), msg.sender, oneToken);
        emit Faucet(msg.sender, oneToken);
    }

    function withdrawEther() public onlyOwner {
        uint256 depositBalance = address(this).balance;
        require(depositBalance > 0, "FlashCoinICO: can not withdraw 0 ether");

        payable(Ownable.owner()).sendValue(depositBalance);
        emit Withdraw(Ownable.owner(), depositBalance);
    }
}
