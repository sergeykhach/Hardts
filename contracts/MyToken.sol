// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
//es tokennel ogtagorcvelu a golosavaniya hamar ov uni kara golos ani, yst hzorutyan yst qanki
contract MyToken is ERC20 {
  constructor() ERC20("MyToken", "MTK", 1000) {}
}