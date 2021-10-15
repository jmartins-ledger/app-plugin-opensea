import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, SPECULOS_ADDRESS, RANDOM_ADDRESS, txFromEtherscan } from './test.fixture';
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

const contractAddr = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
const pluginName = "opensea";
const abi_path = `../${pluginName}/abis/` + contractAddr + '.json';
// const abi = require(abi_path);

// from https://etherscan.io/tx/0x0a863562ee39b566d2eac1d11f0bcefab4fac12c26dc300fa8ad0df3a142afad
test('[Nano S] approve registry', zemu("nanos", async (sim, eth) => {
  const serializedTx = txFromEtherscan("0x02f87001138459682f0085103743e1af8307e31394a5409ec958c83c3f309868babaca7c86dcb077c18084ddd81f82c001a0ac03b62363de842c8afe05d632ab797f2c4d4dadca670586a2ec9515f97d6379a004b94348bb042f63b4581d8e2a3c03058c5f3f67d9d4e80d36fd6b73c54e48be");
  const tx = eth.signTransaction(
    "44'/60'/0'/0",
    serializedTx,
  );
  await waitForAppScreen(sim);
  await sim.navigateAndCompareSnapshots('.', 'nanos_approve_registry', [6, 0]);
  await tx;
}));