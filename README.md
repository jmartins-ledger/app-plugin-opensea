# OpenSea plugin

This is an app plugin for the [Ethereum application](https://github.com/LedgerHQ/app-ethereum) on Ledger Nano S and X cold-storage devices.

The plugin improves displayed information on Nano screen devices to a human readable format, which improves security by informing the user of transaction data.

## OpenSea interface

Most transactions emitted on Ethereum by an OpenSea user come from the [OpenSea contract](https://etherscan.io/address/0x7be8076f4ea4a4ad08075c2508e481d6c946d12b).

### The plugin supports:

- CancelOrder_ method.
- AtomicMatch_ method.
- RegisterProxy (method from a different contract: [OpenSea: Registry](https://etherscan.io/address/0xa5409ec958c83c3f309868babaca7c86dcb077c1)).

### Not supported:

- SetApprovalForAll (specific to collection method, needed to allow OpenSea to "spend" user's NFT's meaning to transfer them once sale is triggered).
- ProxyAssert (specific to collection method, used to transfer several items from one owner to an other. (Not a sale)).

- Many interactions on the OpenSea platform require solely a signature from the Ledger device: Creating a collection, placing a bid, putting an item on sale, lowering said sale-price.

## Compilation

To compile: `make DEBUG=10`

This plugin uses the [ethereum-plugin-sdk](https://github.com/LedgerHQ/ethereum-plugin-sdk.git). If there's an error while building, try running `git pull --recurse-submodules` in order to update the sdk. If this fixes your bug, please file an issue or create a PR to add the new sdk version 🙂

If you need to update the sdk, you will need to do it locally and create a PR on the ethereum-plugin-sdk repo.

## Testing

The tests consist of screenshots being compared and having to match a set of correct screenshots located in the `opensea-plugin/tests/snapshots` directory.

To run the tests:

`cd opensea-plugin/tests/`

`yarn test -t NAME_OF_TEST` where NAME_OF_TEST is the string associated to the singular test name.

The name of the singular tests may be found in `opensea-plugin/tests/src/*.test.js.`

<b>OR</b>

Simply run `yarn test` to run all tests.

The name of the singular tests may be found in opensea-plugin/tests/src/*.test.js.

## Documentation

For more information about how the plugin and tester works visit the [plugin documentation page](https://hackmd.io/300Ukv5gSbCbVcp3cZuwRQ).
