import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploySimpleDex: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // Forzar chainId directamente desde la configuración de red
  const chainId = hre.network.config.chainId || 31337;

  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Obtener las direcciones de los tokens ya desplegados
  const tokenADeployment = await hre.deployments.get("TokenA");
  const tokenBDeployment = await hre.deployments.get("TokenB");

  // Desplegar SimpleDex con las direcciones de los tokens existentes
  const simpleDex = await deploy("SimpleDEX", {
    from: deployer,
    args: [tokenADeployment.address, tokenBDeployment.address],
    log: true,
    autoMine: true,
  });

  console.log(`SimpleDEX desplegado en: ${simpleDex.address}`);
};

export default deploySimpleDex;

deploySimpleDex.tags = ["SimpleDEX"];
deploySimpleDex.dependencies = ["TokenA", "TokenB"];