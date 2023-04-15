//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    mapping(address => mapping(address => uint256)) public tokens;
    mapping (uint256 => _Order) orders;
    uint256 public  orderCount;

    struct _Order {
        uint256 id;
         address user;
        address tokenGet;
        uint256 amountGet;
        address tokenGive;
        uint256 amountGive;
        uint256 timestamp;

        
      }

    event Deposit(address token, 
      address user,
      uint256 amount,
      uint256 balance
      );

    event Withdraw(
        address token,
        address user,
        uint256 amount,
        uint256 balance
    );

        
    event Order(
        uint256 id,
         address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp 
        );

    constructor(address _feeAccount, uint256 _feePercent) {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }


    // ------------------------
    // DEPOSIT & WITHDRAW TOKEN

    function depositToken(address _token, uint256 _amount) public {
        // Transfer tokens to exchange
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));

        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] + _amount;

        // Emit an event
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function withdrawToken(address _token, uint256 _amount) public {
        // Ensure user has enough tokens to withdraw
        require(tokens[_token][msg.sender] >= _amount);

        // Transfer tokens to user
        Token(_token).transfer(msg.sender, _amount);

        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount;

        // Emit event
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function balanceOf(address _token, address _user)
        public
        view
        returns (uint256)
    {
        return tokens[_token][_user];
    }

    function makeOrders( address tokenGet, uint256 amountGet, address tokenGive, uint256 amountGive )  public {
         require(balanceOf(tokenGive,msg.sender) >= amountGive);
          orderCount++;
        orders[orderCount] = _Order(orderCount,
                                    msg.sender,
                                    tokenGet,
                                    amountGet,
                                    tokenGive,
                                    amountGive,
                                    block.timestamp
                                    );

        emit Order(orderCount,msg.sender,tokenGet,amountGet,tokenGive,amountGive,block.timestamp);

       }

}
