// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//ay es contracti hamar menq governence enq anelu , sran enq karavarelu
//aysinqn bolor haraberutyunnery u txnery ays kontracti het anelu enq voch te ughaki ayl governancov

contract Demo {
  string public message;
  mapping(address => uint) public balances;
  address public owner;

  constructor() {
    owner = msg.sender;
  }
//ownery karuma tal contracty _to in
  function transferOwnership(address _to) external {
    require(msg.sender == owner);
    owner = _to;
  }

  function pay(string calldata _message) external payable {
    require(msg.sender == owner); //tirojic baci voch mek chi kara
    message = _message;
    balances[msg.sender] = msg.value;
  }
}
