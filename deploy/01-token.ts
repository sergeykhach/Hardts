import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();
//arajiny es enq deploy anum
  await deploy("MyToken", {
    from: deployer,
    log: true
  });
}

export default func;
func.tags = ['MyToken'];