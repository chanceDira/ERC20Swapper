// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface ERC20Swapper {
    function swapEtherToToken(address _token, uint256 _minAmount)
        external
        payable
        returns (uint256);

    function sellTokens(address _token, uint256 _amount) external;
}

contract SimpleERC20Swapper is ERC20Swapper {
    address public owner;
    uint256 public rate = 15470;
    bool public paused = false;

    event TokensPurchased(
        address indexed account,
        address indexed token,
        uint256 amount,
        uint256 rate
    );
    event TokensSold(
        address indexed account,
        address indexed token,
        uint256 amount,
        uint256 rate
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Paused(address account);
    event Unpaused(address account);
    event RateUpdated(uint256 oldRate, uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function pause() public onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function updateRate(uint256 _newRate) public onlyOwner {
        require(_newRate > 0, "New rate must be greater than zero");
        emit RateUpdated(rate, _newRate);
        rate = _newRate;
    }

    function swapEtherToToken(address _token, uint256 _minAmount)
        external
        payable
        override
        whenNotPaused
        returns (uint256)
    {
        require(msg.value > 0, "Must send Ether to swap");

        ERC20 erc20 = ERC20(_token);

        uint256 tokenAmount = msg.value * rate;
        require(tokenAmount >= _minAmount, "Insufficient token amount");
        require(
            erc20.balanceOf(address(this)) >= tokenAmount,
            "Contract does not have enough tokens"
        );

        require(
            erc20.transfer(msg.sender, tokenAmount),
            "Token transfer failed"
        );

        emit TokensPurchased(msg.sender, _token, tokenAmount, rate);

        return tokenAmount;
    }

    function sellTokens(address _token, uint256 _amount)
        external
        override
        whenNotPaused
    {
        ERC20 erc20 = ERC20(_token);

        require(
            erc20.balanceOf(msg.sender) >= _amount,
            "Insufficient token balance"
        );

        uint256 etherAmount = _amount / rate;
        require(
            address(this).balance >= etherAmount,
            "Contract does not have enough Ether"
        );

        require(
            erc20.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed"
        );

        bool sent = payable(msg.sender).send(etherAmount);
        require(sent, "Failed to send Ether");

        emit TokensSold(msg.sender, _token, _amount, rate);
    }

    receive() external payable {}

    function balanceOfEiger(address _token) external view returns (uint256) {
        ERC20 erc20 = ERC20(_token);
        return erc20.balanceOf(msg.sender);
    }
}

// Sepolia Testnet
// contract address: 0x598B79010FCE60CA10457e92FD3e411860Bd665a
