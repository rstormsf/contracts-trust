pragma solidity ^0.4.23;


import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";


/**
 * @title Token Holder with vesting period
 * @dev holds any amount of tokens and allows to withdraw selected number of tokens after every 6 months (183 days)
 */
contract TokenHolder is Ownable {
    using SafeMath for uint;

    event Released(uint amount);

    /**
     * @dev every 6 (183 days) months owner can withdraw value tokens
     */
    uint constant public vestingInterval = 86400 * 183;
    /**
     * @dev start of the vesting period
     */
    uint public start;
    /**
     * @dev already withdrawn value
     */
    uint public released;
    /**
     * @dev value can be withdrawn every 6 months
     */
    uint public value;
    /**
     * @dev holding token
     */
    ERC20Basic public token;

    constructor(uint _start, uint _value, ERC20Basic _token) public {
        start = _start;
        value = _value;
        token = _token;
    }

    /**
     * @dev transfers vested tokens to beneficiary (to the owner of the contract)
     * @dev automatically calculates amount to release
     */
    function release() onlyOwner public {
        uint toRelease = calculateVestedAmount().sub(released);
        uint left = token.balanceOf(this);
        if (left < toRelease) {
            toRelease = left;
        }
        require(toRelease > 0, "nothing to release");
        require(token.transfer(msg.sender, toRelease));
        emit Released(toRelease);
        released = released.add(toRelease);
    }

    function calculateVestedAmount() view internal returns (uint) {
        return now.sub(start).div(vestingInterval).mul(value);
    }
}
