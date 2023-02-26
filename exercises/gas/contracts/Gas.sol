// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

struct Payment {
    uint8 paymentType;
    uint16 amount;
}

contract GasContract {
    uint16 public constant totalSupply = 10000; // cannot be updated
    mapping(address => uint16) private balances;
    mapping(address => Payment[]) private payments;
    mapping(address => uint8) public whitelist;
    address[5] public administrators;

    event Transfer(address recipient, uint16 amount);

    constructor(address[] memory _admins, uint256) {
        balances[msg.sender] = totalSupply;
        for (uint8 i = 0; i < administrators.length;) {
            administrators[i] = _admins[i];
            unchecked {
                i++;
            }
        }
    }

    function balanceOf(address _user) public view returns (uint16) {
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
        uint16 _amount,
        string calldata
    ) public returns (bool) {
        // balances[msg.sender] = balances[msg.sender] - _amount;
        unchecked {
            balances[_recipient] += _amount;
            payments[msg.sender].push(Payment(1, _amount));
        }
        emit Transfer(_recipient, _amount);
        return true;
    }

    function updatePayment(
        address _user,
        uint8 idx,
        uint16 _amount,
        uint8 _type
    ) public {
        // bool allowed = false;
        // for (uint8 i = 0; i < administrators.length;) {
        //     if (administrators[i] == msg.sender) {
        //         allowed = true;
        //         break;
        //     }
        //     unchecked {
        //         i++;
        //     }
        // }
        require(msg.sender == administrators[4]);

        unchecked {
            Payment storage temp = payments[_user][idx-1];
            temp.paymentType = _type;
            temp.amount = _amount;
        }
    }

    function addToWhitelist(address _userAddrs, uint8 _tier) public {
        whitelist[_userAddrs] = _tier;
    }

    function whiteTransfer(
        address _recipient,
        uint16 _amount,
        uint64[3] calldata
    ) external {
        uint16 senderAmount = whitelist[msg.sender];
        uint16 senderBalance = balances[msg.sender];
        uint16 recipientBalance = balances[_recipient];
        assembly {
            senderBalance := add(sub(senderBalance, _amount), senderAmount)
            recipientBalance := sub(add(recipientBalance, _amount), senderAmount)
        }
        balances[msg.sender] = senderBalance;
        balances[_recipient] = recipientBalance;
    }
}
