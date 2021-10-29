//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract NFTContract is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;         
        uint256 lastUpdateTime;   
        uint256 pointsDebt;     
    }
    
    struct NFTInfo {
        address contractAddress;
        uint256 id;             
        uint256 remaining;      
        uint256 price;          
    }
    
    uint256 public totalNFT;
    uint256 public emissionRate;      
    IERC20 lpToken;                    
    
    event Deposit(address indexed sender, uint256 amount, uint256 lastUpdateTime);


    NFTInfo[] public nftInfo;
    mapping(address => UserInfo) public userInfo;
    address private _owner;

    constructor(uint256 _emissionRate, IERC20 _lpToken) {
        emissionRate = _emissionRate;
        lpToken = _lpToken;
    }
    
    
   /* function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwnerModifies() {
        require(owner() == msg.sender, "Not owner");
        _;
    } */

    modifier notContract(){
        require(msg.sender == tx.origin, "Please don't do with proxy contract");
        _;
    }

    function addNFT( address contractAddress, uint256 id, uint256 total, uint256 price) external onlyOwner{
        ERC1155(contractAddress).safeTransferFrom(msg.sender, address(this), id, total, "");
        nftInfo.push(NFTInfo({
            contractAddress: contractAddress,
            id: id,
            remaining: total,
            price: price
        }));
    }
    
    function deposit(uint256 _amount) external notContract{
        require(_amount > 0, "Nothing to deposit");
        lpToken.safeTransferFrom( msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender];
        

        if(user.amount != 0) {
            user.pointsDebt = pointsBalance(msg.sender);
        }

        totalNFT = totalNFT.add(_amount);
        user.amount = user.amount.add(_amount);
        user.lastUpdateTime = block.timestamp;

        emit Deposit((msg.sender), _amount, block.timestamp);
    }

    function claimNFT(uint256 _nftIndex, uint256 _quantity) public {
        NFTInfo storage nft = nftInfo[_nftIndex];
        require(nft.remaining > 0, "All NFTs farmed");
        require(pointsBalance(msg.sender) >= nft.price.mul(_quantity), "Insufficient Points");
        UserInfo storage user = userInfo[msg.sender];
        
        
        user.pointsDebt = pointsBalance(msg.sender).sub(nft.price.mul(_quantity));
        user.lastUpdateTime = block.timestamp;
        
        // transfer nft
        ERC1155(nft.contractAddress).safeTransferFrom( address(this), msg.sender, nft.id, _quantity, "");
        
        nft.remaining = nft.remaining.sub(_quantity);
    }

     function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(_amount > 0, "Nothing to withdraw");
        require(user.amount >= _amount, "Insufficient staked");
        
        // update userInfo
        user.pointsDebt = pointsBalance(msg.sender);
        user.amount = user.amount.sub(_amount);
        totalNFT = totalNFT.sub(_amount);
        user.lastUpdateTime = block.timestamp;
        
        lpToken.safeTransfer( msg.sender, _amount);
    }

    function withdrawAll() external notContract {
        withdraw(userInfo[msg.sender].amount);
    }


    function pointsBalance(address userAddress) public view returns (uint256) {
        UserInfo memory user = userInfo[userAddress];
        return user.pointsDebt.add(_unBalancePoints(user));
    }

    function _unBalancePoints(UserInfo memory user) internal view returns (uint256) {
        return block.timestamp.sub(user.lastUpdateTime).mul(emissionRate).mul(user.amount);
    }
}