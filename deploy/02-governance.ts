import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments; //get-y hatuk funkciayi vori mijocov karum enq gtnenq arden deploy arac contracty u masn ira hascen

  const { deployer } = await getNamedAccounts();

  const token = await get("MyToken"); //orinak stegh
//
  await deploy("Governance", {
    from: deployer,
    args: [token.address], //aystegh cuyc enq talis vor tokenov eq golos anum
    log: true
  });
}

export default func;
func.tags = ['Governance'];
