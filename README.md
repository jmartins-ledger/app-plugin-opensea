### OpenSea plugin

This is an app plugin for the [Ethereum application](https://github.com/LedgerHQ/app-ethereum) on Ledger Nano S and X cold-storage devices.

The plugin improves displayed information on Nano screen devices to a human readable format, which improves security by informing the user of transaction data.

## OpenSea interface

Most transactions emitted by OpenSea on Ethereum come from the [OpenSea contract](https://etherscan.io/address/0x7be8076f4ea4a4ad08075c2508e481d6c946d12b).

# The plugin supports:

1- CancelOrder_ method.
2- AtomicMatch_ method.
3- RegisterProxy (method from a different contract: [OpenSea: Registry](https://etherscan.io/address/0xa5409ec958c83c3f309868babaca7c86dcb077c1)).

# Not supported:

1- SetApprovalForAll (specific to collection method, needed to allow OpenSea to "spend" user's NFT's meaning to transfer them once sale is triggered.).
2- ProxyAssert (specific to collection method, used to transfer several items from one owner to an other. (Not a sale)).

3- Many interactions on the OpenSea platform require solely a signature from the Ledger device: Creating a collection, placing a bid, putting an item on sale, lowering said sale-price.

## Testing

The tests consist of screenshots being compared and having to match a set of correct screenshots located in the tests/snapshots directory.

To run the tests:
`cd opensea-plugin/tests/`
`yarn test -t NAME_OF_TEST` where NAME_OF_TEST is the string associated to the singular test name.

The name of the singular tests may be found in `opensea-plugin/tests/src/*.test.js`.
