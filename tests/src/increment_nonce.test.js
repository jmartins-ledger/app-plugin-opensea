import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, txFromEtherscan, boilerplateJSON, resolutionConfig, loadConfig } from './test.fixture';
import ledgerService from "@ledgerhq/hw-app-eth/lib/services/ledger"

// https://etherscan.io/tx/0x72937bfe0b748d852bd0fa326b1000a42bc307a31485b6d9259a786efc82c29c
test('[Nano S] increment_nonce', zemu("nanos", async (sim, eth) => {
    const serializedTx = txFromEtherscan("0x02f8700181d08459682f0085164810f06b82b099947f268357a8c2552623316e2562d90e642bb538e58084627cdcb9c001a0cbeb8887a4fde5855087183d841997b89878c8bcb77a6b7ce43018def8aabdd8a0778979e7afc3753c80c4a0df98232bde9493ce7f73c70a19c4131ffa6f1ec5df");
    const resolution = await ledgerService.resolveTransaction(
      serializedTx,
      loadConfig,
      resolutionConfig
    );
    const tx = eth.signTransaction(
      "44'/60'/0'/0",
      serializedTx,
      resolution
    );
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', 'increment_nonce', [8, 0]);
    await tx;
  }));