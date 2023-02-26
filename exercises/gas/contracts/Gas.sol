// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    uint256 public constant totalSupply = 10000; // cannot be updated
    mapping(address => uint256) private balances;
    address public contractOwner;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;
    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend
    }

    struct Payment {
        PaymentType paymentType;
        uint256 amount;
    }

    struct ImportantStruct {
        uint8 valueA; // max 3 digits
        uint256 bigValue;
        uint8 valueB; // max 3 digits
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[] memory _admins, uint256) {
        balances[msg.sender] = totalSupply;
        for (uint8 i = 0; i < administrators.length; i++) {
            administrators[i] = _admins[i];
        }
    }

    function checkForAdmin(address _user) public view returns (bool) {
        for (uint256 i = 0; i < administrators.length; i++) {
            if (administrators[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() public pure returns (bool) {
        return true;
    }

    function getPayments(address _user) public view returns (Payment[] memory) {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) public returns (bool) {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        payments[msg.sender].push(Payment(PaymentType.BasicPayment, _amount));
        return true;
    }

    function updatePayment(
        address _user,
        uint8,
        uint256 _amount,
        PaymentType _type
    ) public {
        require(checkForAdmin(msg.sender));

        Payment[] storage userPayments = payments[_user];
        for (uint8 i = 0; i < userPayments.length; i++) {
            Payment storage temp = userPayments[i];
            temp.paymentType = _type;
            temp.amount = _amount;
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        whitelist[_userAddrs] = _tier;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct calldata
    ) public {
        uint256 senderAmount = whitelist[msg.sender];
        balances[msg.sender] = balances[msg.sender] - _amount + senderAmount;
        balances[_recipient] = balances[_recipient] + _amount - senderAmount;
    }
}
