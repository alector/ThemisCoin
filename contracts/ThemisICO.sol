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
    bool private _coinDefined;

    modifier coinIsSet {
        require(_coinDefined, "ThemixICO: You must first set an address of the deployed coin");
        _;
    }

    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

    constructor(address ownerICO) {
        Ownable.transferOwnership(ownerICO);
    }

    function setCoin(address coinAddress_) public onlyOwner {
        // TO DO: REQUIRE NO ZERO ADDRESS
        _coinAddress = coinAddress_;
        _coin = ThemisCoin(_coinAddress);
        _ownerCoin = _coin.owner();
        _coinDefined = true;
    }

    function getCoinOwner() public view coinIsSet returns (address) {
        return _ownerCoin;
    }

    function getContractAllowance() public view coinIsSet returns (uint256) {
        return _coin.allowance(_ownerCoin, address(this));
    }

    function getCoinAddress() public view coinIsSet returns (address) {
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

    function _buyTokens(address sender, uint256 amount) private coinIsSet whenNotPaused {
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

    function faucetCoin() public coinIsSet whenNotPaused {
        uint256 oneToken = 1000000000000000000;
        // a large amount of coints have to be previously approved to this contract's address
        _coin.transferFrom(_ownerCoin, msg.sender, oneToken);
    }
}
