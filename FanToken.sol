// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FanToken is ERC20, Ownable {
    struct User {
        string nationalId;
        string bankAccount;
        uint256 tokenBalance;
        uint256 lastTransferTime; // زمان آخرین انتقال
    }
    constructor(address initialOwner) ERC20("FanToken", "FTK") Ownable(msg.sender) {
        transferOwnership(initialOwner);
        _mint(initialOwner, 1000000 * 10 ** decimals()); // Mint 1 million tokens to the initial owner
    }

    mapping(address => User) private users;

    // تابع برای ثبت اطلاعات کاربر
    function registerUser(string memory _nationalId, string memory _bankAccount) public {
        require(bytes(users[msg.sender].nationalId).length == 0, "User already registered");

        users[msg.sender] = User({
        nationalId: _nationalId,
        bankAccount: _bankAccount,
        tokenBalance: 0,
        lastTransferTime: block.timestamp
        });
    }

    // تابع برای افزودن توکن به موجودی کاربر
    function addTokens(uint256 amount) public {
        require(bytes(users[msg.sender].nationalId).length != 0, "User not registered");

        _mint(msg.sender, amount);
        users[msg.sender].tokenBalance += amount;
    }

    // تابع خرید از فروشگاه و کسر توکن
    function spendTokens(uint256 amount) public {
        require(bytes(users[msg.sender].nationalId).length != 0, "User not registered");
        require(users[msg.sender].tokenBalance >= amount, "Not enough tokens");

        users[msg.sender].tokenBalance -= amount;
        _burn(msg.sender, amount); // سوزاندن توکن‌ها
    }

    // تابع برای انتقال 20 درصد از توکن‌ها
    function transferTokens(address to, uint256 amount) public {
        require(bytes(users[msg.sender].nationalId).length != 0, "User not registered");

        uint256 currentTime = block.timestamp;
        require(currentTime >= users[msg.sender].lastTransferTime + 1 days, "You can only transfer once every 24 hours");

        uint256 maxTransferAmount = users[msg.sender].tokenBalance * 20 / 100;
        require(amount <= maxTransferAmount, "Cannot transfer more than 20% of your balance");

        users[msg.sender].tokenBalance -= amount;
        users[to].tokenBalance += amount;

        users[msg.sender].lastTransferTime = currentTime; // بروزرسانی زمان آخرین انتقال
    }

    // تابع برای تغییر اطلاعات کاربر
    function updateUserInfo(string memory _nationalId, string memory _bankAccount) public {
        require(bytes(users[msg.sender].nationalId).length != 0, "User not registered");

        users[msg.sender].nationalId = _nationalId;
        users[msg.sender].bankAccount = _bankAccount;
    }

    // تابع برای مشاهده موجودی توکن کاربر
    function getTokenBalance() public view returns (uint256) {
        return users[msg.sender].tokenBalance;
    }
}