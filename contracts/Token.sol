// Copyright 2018 MustangChain Foundation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity ^0.4.24;

/**
 * Token is an ERC-20 implementation.
 */
contract Token {

/** Transaction success notification. */
event Transfer(address indexed _from, address indexed _to, uint _value);

/** Allowance success notification. */
event Approval(address indexed _owner, address indexed _spender, uint _value);

/** Name recommendation lable. */
string public constant name = "MustangChain Token";
/** Symbol recommendation lable. */
string public constant symbol =  "MUST";

/** Fixed number of tokens. */
uint public constant totalSupply = 100e9;

/** No fractions for token amounts. */
uint8 public constant decimals = 0;


mapping(address => uint) private balances;

mapping(address => mapping(address => uint)) private allowances;


/** Initates the totalSupply to the caller's account. */
constructor()
public {
	balances[msg.sender] = totalSupply;
}

/** Returns the account balance of _owner. */
function balanceOf(address _owner)
public view returns (uint balance) {
	return balances[_owner];
}

/**
 * Transfers an _amount of tokens, fires the Transfer event on success and
 * throws if the caller does not have enough tokens to spend.
 *
 * Note that a transfer of 0 tokens is treated as a normal transfer.
 */
function transfer(address _to, uint _amount)
public returns (bool success) {
	// withdraw from caller
	uint balance = balances[msg.sender];
	require(_amount <= balance, "insufficient funds");
	balances[msg.sender] -= balance - _amount;

	// ammend to addressee
	balances[_to] += _amount;

	// report success
	emit Transfer(msg.sender, _to, _amount);
	return true;
}

/**
 * Transfers an _amount of tokens, fires the Transfer event on success and
 * throws if _from does not have enough tokens to spend.
 *
 * The transferFrom method is used for a withdraw workflow, allowing contracts
 * to transfer tokens on your behalf. This can be used for example to allow a
 * contract to transfer tokens on your behalf and/or to charge fees in
 * sub-currencies. The function throws unless _from has deliberately authorized
 * the caller via some mechanism.
 *
 * Note that a transfer of 0 tokens is treated as a normal transfer.
 */
function transferFrom(address _from, address _to, uint _amount)
public returns (bool success) {
	// need allowance for caller
	uint allowance = allowances[_from][msg.sender];
	require(_amount <= allowance, "insufficient allowance");

	// check available tokens
	uint balance = balances[_from];
	require(_amount <= balance, "insufficient funds");

	// deduct allowance with withdrawal
	allowances[_from][msg.sender] = allowance - _amount;
	balances[_from] = balance - _amount;

	// ammend to addressee
	balances[_to] += _amount;

	// report success
	emit Transfer(_from, _to, _amount);
	return true;
}

/**
 * Sets the _amount of tokens which _spender is allowed to withdraw from the
 * caller.
 *
 * Existing approvals should not be ammended due to a race condition.
 * https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit?usp=sharing
 */
function approve(address _spender, uint _amount)
public returns (bool success) {
	allowances[msg.sender][_spender] = _amount;

	// report success
	emit Approval(msg.sender, _spender, _amount);
	return true;
}

/**
 * Returns the amount of tokens which _spender is allowed to withdraw from
 * _owner.
 */
function allowance(address _owner, address _spender)
public view returns (uint remaining) {
	return allowances[_owner][_spender];
}

}
