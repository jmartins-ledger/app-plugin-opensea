"use strict";

var _zemu = _interopRequireDefault(require("@zondax/zemu"));

var _hwAppEth = _interopRequireDefault(require("@ledgerhq/hw-app-eth"));

var _generate_plugin_config = require("./generate_plugin_config");

var _utils = require("ethers/lib/utils");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const transactionUploadDelay = 120000;

async function waitForAppScreen(sim) {
  await sim.waitUntilScreenIsNot(sim.getMainMenuSnapshot(), transactionUploadDelay);
}

const sim_options_generic = {
  logging: true,
  X11: true,
  startDelay: 5000,
  custom: ''
};

const Resolve = require('path').resolve;

const NANOS_ETH_PATH = Resolve('elfs/ethereum_nanos.elf');
const NANOX_ETH_PATH = Resolve('elfs/ethereum_nanox.elf');
const NANOS_PLUGIN_PATH = Resolve('elfs/plugin_nanos.elf');
const NANOX_PLUGIN_PATH = Resolve('elfs/plugin_nanox.elf'); // Edit this: replace `Boilerplate` by your plugin name

const NANOS_PLUGIN = {
  "OpenSea": NANOS_PLUGIN_PATH
};
const NANOX_PLUGIN = {
  "OpenSea": NANOX_PLUGIN_PATH
};
const boilerplateJSON = (0, _generate_plugin_config.generate_plugin_config)();
console.log(boilerplateJSON);
const SPECULOS_ADDRESS = '0xFE984369CE3919AA7BB4F431082D027B4F8ED70C';
const RANDOM_ADDRESS = '0xaaaabbbbccccddddeeeeffffgggghhhhiiiijjjj';
let genericTx = {
  nonce: Number(0),
  gasLimit: Number(21000),
  gasPrice: (0, _utils.parseUnits)('1', 'gwei'),
  value: (0, _utils.parseEther)('1'),
  chainId: 1,
  to: RANDOM_ADDRESS,
  data: null
};
const TIMEOUT = 1000000;
const resolutionConfig = {
  externalPlugins: true,
  nft: false,
  erc20: true
};
const loadConfig = {
  nftExplorerBaseURL: "https://nft.api.live.ledger.com/v1/ethereum",
  pluginBaseURL: "https://cdn.live.ledger.com",
  extraPlugins: boilerplateJSON
}; // Generates a serializedTransaction from a rawHexTransaction copy pasted from etherscan.

function txFromEtherscan(rawTx) {
  // Remove 0x prefix
  rawTx = rawTx.slice(2);
  let txType = rawTx.slice(0, 2);

  if (txType == "02" || txType == "01") {
    // Remove "02" prefix
    rawTx = rawTx.slice(2);
  } else {
    txType = "";
  }

  let decoded = _utils.RLP.decode("0x" + rawTx);

  if (txType != "") {
    decoded = decoded.slice(0, decoded.length - 3); // remove v, r, s
  } else {
    decoded[decoded.length - 1] = "0x"; // empty

    decoded[decoded.length - 2] = "0x"; // empty

    decoded[decoded.length - 3] = "0x01"; // chainID 1
  } // Encode back the data, drop the '0x' prefix


  let encoded = _utils.RLP.encode(decoded).slice(2); // Don't forget to prepend the txtype


  return txType + encoded;
}

function zemu(device, func) {
  return async () => {
    jest.setTimeout(TIMEOUT);
    let eth_path;
    let plugin;
    let sim_options = sim_options_generic;

    if (device === "nanos") {
      eth_path = NANOS_ETH_PATH;
      plugin = NANOS_PLUGIN;
      sim_options.model = "nanos";
    } else {
      eth_path = NANOX_ETH_PATH;
      plugin = NANOX_PLUGIN;
      sim_options.model = "nanox";
    }

    const sim = new _zemu.default(eth_path, plugin);

    try {
      await sim.start(sim_options);
      const transport = await sim.getTransport();
      const eth = new _hwAppEth.default(transport); // eth.setLoadConfig({
      //     // baseURL: null,
      //     extraPlugins: boilerplateJSON,
      //     // nftExplorerBaseURL: "https://nft.api.live.ledger.com/v1/ethereum",
      //     // pluginBaseURL: null,
      // })

      eth.setLoadConfig(resolutionConfig);
      await func(sim, eth);
    } finally {
      await sim.close();
    }
  };
}

module.exports = {
  zemu,
  waitForAppScreen,
  genericTx,
  SPECULOS_ADDRESS,
  RANDOM_ADDRESS,
  txFromEtherscan,
  resolutionConfig,
  loadConfig
};