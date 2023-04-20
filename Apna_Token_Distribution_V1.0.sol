// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TokenDistribution {
    address public owner;
    IERC20 token;
    uint256 totalAccountTransfer;
    uint256 maxTransfer;
    mapping(address => bool) public alreadyPaid;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not the owner!");
        _;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "not valid address");
        token = IERC20(tokenAddress);
    }

    function setmaxTransfer(uint256 max) external onlyOwner {
        maxTransfer = max;
    }

    function resetTotalAccountTransfer() external onlyOwner {
        totalAccountTransfer = 0;
    }

    function getMaxTransfer() external view returns (uint256) {
        return maxTransfer;
    }

    function getTokenAddress() external view returns (IERC20) {
        return IERC20(token);
    }

    function getTotalAccountTransfer() external view returns (uint256) {
        return totalAccountTransfer;
    }

    function tokensDistribution(
        address[] memory accounts,
        uint256 amount
    ) external payable onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (accounts[i] != address(0) && !alreadyPaid[accounts[i]]) {
                totalAccountTransfer++;
                if (totalAccountTransfer <= maxTransfer) {
                    alreadyPaid[accounts[i]] = true;
                    token.transfer(accounts[i], amount);
                } else {
                    break;
                }
            } else {
                continue;
            }
        }
    }

    function tokensWithdraw(address tokenAddress) external onlyOwner {
        IERC20 wToken;
        wToken = IERC20(tokenAddress);
        wToken.transfer(msg.sender, wToken.balanceOf(address(this)));
    }
}
