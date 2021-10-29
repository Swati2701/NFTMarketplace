/* eslint-disable */
const hre = require("hardhat");

async function main() {
  // write the deploy script here

  const ERC20Creation = await hre.ethers.getContractFactory("ERC20Creation");
  const erc20Creation = await ERC20Creation.deploy('1000000000');
  await erc20Creation.deployed();
  console.log("erc20 deployed to:", erc20Creation.address);

  const NFTMarket = await hre.ethers.getContractFactory("NFTContract");
  const nftMarket = await NFTMarket.deploy();
  //console.log(nftMarket);
  await nftMarket.deployed();
  console.log("nftMarket deployed to:", nftMarket.address);


  const TokenCreation = await hre.ethers.getContractFactory("TokenCreation");
  //const nft = await NFT.deploy(nftMarket.address);
  const tokenCreation = await TokenCreation.deploy();
  await tokenCreation.deployed();
  console.log("ERC721 deployed to:", tokenCreation.address);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });