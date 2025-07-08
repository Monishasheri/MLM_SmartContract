// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract MLM {
    uint public _id = 1;
    IERC20 public token;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);

        address rootAddress = 0x3B6E6168c0335261c6e1A006323B7667AfBddc7b;
        users[rootAddress] = UserData({
            id: _id,
            userAccount: rootAddress,
            refAccount: address(0),
            amount: 100,
            refAmount: 0
        });
        isUserExists[rootAddress] = true;
    }

    struct UserData {
        uint id;
        address userAccount;
        address refAccount;
        uint amount;
        uint refAmount;
    }

    mapping(address => bool) public isUserExists;
    mapping(address => UserData) public users;

    modifier OneUser(address _account, address _refAccount) {
        require(!isUserExists[_account], "User already registered");
        require(isUserExists[_refAccount], "Referral Not Found");
        _;
    }

    function addUser(
        address _account,
        address _refAccount,
        uint _amount
    ) external OneUser(_account, _refAccount) {
        require(_amount > 0, "Amount must be > 0");

        // 1. Transfer token from user to contract
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed"
        );

        // 2. Store user data
        _id += 1;
        users[_account] = UserData({
            id: _id,
            userAccount: _account,
            refAccount: _refAccount,
            amount: _amount,
            refAmount: 0
        });

        isUserExists[_account] = true;

        // 3. Distribute rewards to up to 3 referrers
        address acc = _refAccount;
        uint256[3] memory refPercents = [uint256(50), uint256(30), uint256(20)];

        for (uint i = 0; i < 3; i++) {
            if (acc == address(0) || !isUserExists[acc]) break;

            uint reward = (_amount * refPercents[i]) / 100;
            users[acc].refAmount += reward;

            // Transfer reward to the referrer
            require(token.transfer(acc, reward), "Reward transfer failed");

            acc = users[acc].refAccount;
        }
    }
}
