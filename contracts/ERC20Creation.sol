// SPDX-License-Idetifier: MIT
//SPDX-License-Identifier: GPL-2.0
//SPDX-License-Identifier: GPL-2.0+

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Creation is ERC20 {
   
    constructor(uint256 initialSupply)  ERC20("NFTToken", "NFT")  {
        _mint(msg.sender, initialSupply * (10 ** 18));
    }
}