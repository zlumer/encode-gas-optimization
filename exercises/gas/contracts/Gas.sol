// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

struct Payment {
    uint256 paymentType;
    uint256 amount;
}

contract GasContract {
    mapping(address => uint256) private balances;
    mapping(address => Payment[]) private payments;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;

    event Transfer(address, uint256);

    constructor(address[5] memory _admins, uint256) {
        administrators = _admins;
        assembly {
            mstore(0x0, caller())
            mstore(0x20, balances.slot)
        }
    }

    function totalSupply() public pure returns (uint256) {
        return 10000;
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory)
    {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) external returns (bool) {
        assembly {
            mstore(0x0, _recipient)
            mstore(0x20, balances.slot)
            let slot := keccak256(0x0, 0x40)
            let oldBalance := sload(slot)
            sstore(slot, add(oldBalance, _amount))
        }
        unchecked {
            payments[msg.sender].push(Payment(1, _amount));
        }
        emit Transfer(_recipient, _amount);
        return true;
    }

    function updatePayment(
        address _user,
        uint256 idx,
        uint256 _amount,
        uint256 _type
    ) external {

        unchecked {
            Payment storage temp = payments[_user][idx - 1];
            temp.paymentType = _type;
            temp.amount = _amount;
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external {
        assembly {
            mstore(0x0, _userAddrs)
            mstore(0x20, whitelist.slot)
            let slot := keccak256(0x0, 0x40)
            sstore(slot, _tier)
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        uint64[3] calldata
    ) external {
        assembly {
            // uint256 senderAmount = whitelist[msg.sender];
            mstore(0x0, caller())
            mstore(0x20, whitelist.slot)
            let slot := keccak256(0x0, 0x40)
            let senderAmount := sload(slot)

            let total := sub(_amount, senderAmount)

            // uint256 senderBalance = balances[msg.sender];
            // mstore(0x0, caller()) -- it's already in memory
            mstore(0x20, balances.slot)
            slot := keccak256(0x0, 0x40)
            sstore(slot, sub(sload(slot), total))

            // uint256 recipientBalance = balances[_recipient];
            mstore(0x0, _recipient)
            // mstore(0x20, balances.slot) -- it's already in memory
            slot := keccak256(0x0, 0x40)
            sstore(slot, add(sload(slot), total))
        }
    }
}
