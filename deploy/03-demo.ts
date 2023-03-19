import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("Demo", {
    from: deployer,
    log: true
  });

  const govern = await get("Governance");

  //uzum enq kpnenq demoyin deplo lineluc heto
  const demo = await hre.ethers.getContract(
    "Demo",
    deployer
  );

  const tx = await demo.transferOwnership(govern.address); //demoyi ownershipy talis enq governancin
  await tx.wait();//sapasum enq lini, verevi anum enq nra hamar vor ete urish mekna demoyi tery apa aranc golosi inch uzi kani el imasty vorna
}

export default func; //export enq anum funkcian
func.tags = ['Demo'];