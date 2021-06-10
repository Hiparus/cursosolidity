//SPDX-License-Identifier: CC-BY-4.0

pragma solidity ^0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {
    address payable contractOwner;

    constructor() { 
        contractOwner = payable(msg.sender); 
    }
    
    function whoIsTheOwner() public view returns(address) {
        return contractOwner;
    }
}

contract Mortal is Owned  {
    function kill() public {
        require(msg.sender==0x684BF0F021e1086B18ffD8d13bE3082273cF013e, "Only owner can destroy the contract");
        selfdestruct(contractOwner);
    }
}

contract TicketERC20 is IERC20, Mortal {
    string private myName;
    string private mySymbol;
    uint256 private myTotalSupply;
    uint256 public decimals;

    mapping (address=>uint256) balances;
    mapping (address=>mapping (address=>uint256)) ownerAllowances;

    constructor() {
        myName = "Fichas de Compra de Arte";
        mySymbol = "PINCEL1";
        decimals = 2;
        _mint(msg.sender, (46 * (10 ** decimals)));
    }

    function name() public view returns(string memory) {
        return myName;
    }

    function symbol() public view returns(string memory) {
        return mySymbol;
    }

    function totalSupply() public override view returns(uint256) {
        return myTotalSupply;
    }

    function balanceOf(address tokenOwner) public override view returns(uint256) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public override view returns(uint256) {
        return ownerAllowances[tokenOwner][spender];
    }

    function transfer(address to, uint256 amount) public override  hasEnoughBalance(msg.sender, amount) tokenAmountValid(amount) returns(bool) {
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    } 

    function approve(address spender, uint limit) public override returns(bool) {
        ownerAllowances[msg.sender][spender] = limit;
        emit Approval(msg.sender, spender, limit);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override 
    hasEnoughBalance(from, amount) isAllowed(msg.sender, from, amount) tokenAmountValid(amount)
    returns(bool) {
        balances[from] = balances[from] - amount;
        balances[to] += amount;
        ownerAllowances[from][msg.sender] = amount;
        emit Transfer(from, to, amount);
        return true;
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        myTotalSupply = myTotalSupply + amount;
        balances[account] = balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }
    
    function purchase() public payable {
        require(msg.value >= 10 gwei);
        transfer(msg.sender, 100);
        //                   1,00
        contractOwner.transfer(msg.value);
    }

    modifier hasEnoughBalance(address owner, uint amount) {
        uint balance;
        balance = balances[owner];
        require (balance >= amount); 
        _;
    }

    modifier isAllowed(address spender, address tokenOwner, uint amount) {
        require (amount <= ownerAllowances[tokenOwner][spender]);
        _;
    }

    modifier tokenAmountValid(uint256 amount) {
        require(amount > 0);
        require(amount <= myTotalSupply);
        _;
    }

}
