pragma solidity ^0.4.16;

/**
 * Welcome to the Telegram chat http://www.devsolidity.io/
 */

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
  }

}


contract Pausable is Ownable {

  uint public endDate;

  /**
   * @dev modifier to allow actions only when the contract IS not paused
   */
  modifier whenNotPaused() {
    require(now >= endDate);
    _;
  }

}

contract StandardToken is Token, Pausable {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) internal allowed;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract KeeppetToken is StandardToken {

    string public constant name = "Keeppet Token";
    string public constant symbol = "KPT";
    uint8 public constant decimals = 0;
    address public tokenWallet;

    uint256 public constant INITIAL_SUPPLY = 10000000;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function KeeppetToken(address tokenOwner, uint _endDate) {
        totalSupply = INITIAL_SUPPLY;
        balances[tokenOwner] = INITIAL_SUPPLY;
        endDate = _endDate;
        tokenWallet = tokenOwner;
    }

    function sendTokens(address _to, uint _amount) external onlyOwner {
        require(_amount <= balances[tokenWallet]);
        balances[tokenWallet] -= _amount;
        balances[_to] += _amount;
        Transfer(tokenWallet, msg.sender, _amount);
    }

}

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }

}


contract SalesManager is Ownable {
    using SafeMath for uint256;

    /**
     * Pre-ICO
     * start date 06.12.2017 12:00 PM NYC Time UTC 4
     * end date 17.12.2017 12:00 PM NYC UTC issuecomment-263524729
     * Token amount 10 000 000
     * min eth = 0,0003
     * token price = 0,1$
     * transfer to wallet = NEED wallet
     * */
    // TODO: set actual dates before deploy
    uint public constant startDate = 0;
    uint public constant endDate = 0;
    uint public constant softCap = 700 ether;
    uint public currentFundraiser;

    // ETH 313$ 17.11.2017 token price 0.1$
    // TODO: set actual price before deploy
    // uint tokenPrice = 277008310249308;
    uint tokenPrice = 277008310249308;
    address public tokenAddress = 0x0;
    address public tokenOwner = 0x0;
    address public refundVault = 0x0;

    /**
     * @dev modifier to allow actions only when Pre-ICO end date is now
     */
    modifier isFinished() {
        require(now >= endDate);
        _;
    }

    function SalesManager (address _tokenOwner, address _multiSigWallet) {
        require(_tokenOwner != address(0) && _multiSigWallet != address(0));
        tokenAddress = new KeeppetToken(_tokenOwner, endDate);
        refundVault = new RefundVault(_multiSigWallet);
        tokenOwner = _tokenOwner;
    }

    function () payable public {
        // if (msg.value < 300000000000000 && now <= startDate && now > endDate) revert();
        if (msg.value < 300000000000000) revert();
        buyTokens();
    }

    function buyTokens() internal {
        KeeppetToken tokenHolder = KeeppetToken(tokenAddress);
        uint256 tokens = msg.value.div(tokenPrice);
        uint256 balance = tokenHolder.balanceOf(tokenOwner);
        if (balance < tokens) {
            uint toReturn = tokenPrice.mul(tokens.sub(balance));
            msg.sender.transfer(toReturn);
            sendTokens(balance, msg.value - toReturn);
        } else {
            sendTokens(tokens, msg.value);
        }
    }

    function sendTokens(uint _amount, uint _ethers) internal {
        KeeppetToken tokenHolder = KeeppetToken(tokenAddress);
        tokenHolder.sendTokens(msg.sender, _amount);
        RefundVault refundVaultContract = RefundVault(refundVault);
        currentFundraiser += _ethers;
        refundVaultContract.deposit.value(_ethers)(msg.sender);
    }

    function setTokenPrice(uint newTokenPrice) public onlyOwner {
        tokenPrice = newTokenPrice;
    }

    function sendTokensManually(address _to, uint _amount) public onlyOwner {
        require(_to != address(0));
        KeeppetToken tokenHolder = KeeppetToken(tokenAddress);
        tokenHolder.sendTokens(_to, _amount);
    }

    function checkFunds() public isFinished onlyOwner {
        RefundVault refundVaultContract = RefundVault(refundVault);
        if (currentFundraiser < softCap) {
            // If soft cap is not reached enable refunds
            refundVaultContract.enableRefunds();
        } else {
            // Send eth to multisig
            refundVaultContract.close();
        }
    }
}
