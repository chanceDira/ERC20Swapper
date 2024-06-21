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

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external;
}

contract EigerToken is ERC20 {
    string public name = "Eiger Token";
    string public symbol = "EGR";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    function transfer(address _recipient, uint256 _amount)
        external
        override
        returns (bool)
    {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external override returns (bool) {
        require(balances[_sender] >= _amount, "Insufficient balance");
        require(
            allowances[_sender][msg.sender] >= _amount,
            "Allowance exceeded"
        );
        balances[_sender] -= _amount;
        balances[_recipient] += _amount;
        allowances[_sender][msg.sender] -= _amount;
        emit Transfer(_sender, _recipient, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount)
        external
        override
        returns (bool)
    {
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function balanceOf(address _account)
        external
        view
        override
        returns (uint256)
    {
        return balances[_account];
    }

    function mint(address _account, uint256 _amount) external override {
        balances[_account] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _account, _amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// contract address: 0xEa7C0cB937B95Be1C48c58F24792d2A7DFb7469C