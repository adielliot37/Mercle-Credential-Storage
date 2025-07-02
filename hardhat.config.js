 require("dotenv").config();
require("@nomiclabs/hardhat-ethers");


module.exports = {
  solidity: "0.8.26",
  networks: {
   

    baseSepolia: {
      url: process.env.RPC_URL || "https://sepolia.base.org",
      chainId: 84532,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
     
    }
  }
};
