async function main() {
 
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);
  const CredentialManager = await ethers.getContractFactory("CredentialManager");

 
  const admin = deployer.address;  
  const contract = await CredentialManager.deploy(admin);

 
  await contract.deployed();
  console.log("CredentialManager deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
