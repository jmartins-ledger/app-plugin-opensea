"use strict";

require("core-js/stable");

require("regenerator-runtime/runtime");

var _hwAppEth = _interopRequireDefault(require("@ledgerhq/hw-app-eth"));

var _erc = require("@ledgerhq/hw-app-eth/erc20");

var _zemu = _interopRequireDefault(require("@zondax/zemu"));

var _errors = require("@ledgerhq/errors");

var _jest = require("../jest");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const {
  NANOS_ETH_ELF_PATH,
  NANOX_ETH_ELF_PATH,
  NANOS_LIDO_LIB,
  NANOX_LIDO_LIB,
  sim_options_nanos,
  sim_options_nanox,
  TIMEOUT
} = require("generic.js");

const ORIGINAL_SNAPSHOT_PATH_PREFIX = "snapshots/wrap/";
const SNAPSHOT_PATH_PREFIX = "snapshots/wrap/";
const ORIGINAL_SNAPSHOT_PATH_NANOS = ORIGINAL_SNAPSHOT_PATH_PREFIX + "nanos/";
const ORIGINAL_SNAPSHOT_PATH_NANOX = ORIGINAL_SNAPSHOT_PATH_PREFIX + "nanox/";
const SNAPSHOT_PATH_NANOS = SNAPSHOT_PATH_PREFIX + "nanos/";
const SNAPSHOT_PATH_NANOX = SNAPSHOT_PATH_PREFIX + "nanox/";
test("Wrap nanos", async () => {
  jest.setTimeout(TIMEOUT);
  const sim = new _zemu.default(NANOS_ETH_ELF_PATH, NANOS_LIDO_LIB);

  try {
    await sim.start(sim_options_nanos);
    let transport = await sim.getTransport();
    const eth = new _hwAppEth.default(transport);
    let buffer = Buffer.from("058000002C8000003C800000010000000000000000F8494A8502540BE400830222E0947F39C581F595B53C5CB19BD0B3F8DA6C935E2CA080A4EA598CB0000000000000000000000000000000000000000000000000016345785D89FFFF018080", "hex");
    await eth.setExternalPlugin("0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0", "0xea598cb0"); // Send transaction

    let tx = transport.send(0xe0, 0x04, 0x00, 0x00, buffer);
    let filename;
    await sim.waitUntilScreenIsNot(sim.getMainMenuSnapshot()); // Review tx

    filename = "review.png";
    await sim.snapshot(SNAPSHOT_PATH_NANOS + filename);

    const review = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOS + filename);

    const expected_review = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOS + filename);

    (0, _jest.expect)(review).toEqual(expected_review); // Lido Stake message

    filename = "lido.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOS + filename);

    const lido = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOS + filename);

    const expected_lido = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOS + filename);

    (0, _jest.expect)(lido).toEqual(expected_lido); // Wrap

    filename = "wrap.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOS + filename);

    const wrap = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOS + filename);

    const expected_wrap = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOS + filename);

    (0, _jest.expect)(wrap).toEqual(expected_wrap); // Max Fees

    filename = "fees.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOS + filename);

    const fees = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOS + filename);

    const expected_fees = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOS + filename);

    (0, _jest.expect)(fees).toEqual(expected_fees); // Accept

    filename = "accept.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOS + filename);

    const accept = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOS + filename);

    const expected_accept = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOS + filename);

    (0, _jest.expect)(accept).toEqual(expected_accept);
    await sim.clickBoth();
    await (0, _jest.expect)(tx).resolves.toEqual(Buffer.from([]));
  } finally {
    await sim.close();
  }
});
test.skip("Wrap nanox", async () => {
  jest.setTimeout(TIMEOUT);
  const sim = new _zemu.default(NANOX_ETH_ELF_PATH, NANOX_LIDO_LIB);

  try {
    await sim.start(sim_options_nanox);
    let transport = await sim.getTransport();
    const eth = new _hwAppEth.default(transport);
    let buffer = Buffer.from("058000002C8000003C800000010000000000000000F8494A8502540BE400830222E0947F39C581F595B53C5CB19BD0B3F8DA6C935E2CA080A4EA598CB0000000000000000000000000000000000000000000000000016345785D89FFFF018080", "hex");
    await eth.setExternalPlugin("0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0", "0xea598cb0"); // Send transaction

    let tx = transport.send(0xe0, 0x04, 0x00, 0x00, buffer);
    let filename;
    await sim.waitUntilScreenIsNot(sim.getMainMenuSnapshot()); // Review tx

    filename = "review.png";
    await sim.snapshot(SNAPSHOT_PATH_NANOX + filename);

    const review = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOX + filename);

    const expected_review = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOX + filename);

    (0, _jest.expect)(review).toEqual(expected_review); // Lido Wrap message

    filename = "lido.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOX + filename);

    const lido = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOX + filename);

    const expected_lido = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOX + filename);

    (0, _jest.expect)(lido).toEqual(expected_lido); // Wrap

    filename = "wrap.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOS + filename);

    const wrap = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOS + filename);

    const expected_wrap = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOS + filename);

    (0, _jest.expect)(wrap).toEqual(expected_wrap); // Max Fees

    filename = "fees.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOX + filename);

    const fees = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOX + filename);

    const expected_fees = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOX + filename);

    (0, _jest.expect)(fees).toEqual(expected_fees); // Accept

    filename = "accept.png";
    await sim.clickRight(SNAPSHOT_PATH_NANOX + filename);

    const accept = _zemu.default.LoadPng2RGB(SNAPSHOT_PATH_NANOX + filename);

    const expected_accept = _zemu.default.LoadPng2RGB(ORIGINAL_SNAPSHOT_PATH_NANOX + filename);

    (0, _jest.expect)(accept).toEqual(expected_accept);
    await sim.clickBoth();
    await (0, _jest.expect)(tx).resolves.toEqual(Buffer.from([]));
  } finally {
    await sim.close();
  }
});