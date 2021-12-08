import struct
import argparse
from binascii import hexlify, unhexlify

DEFAULT_SIGNATURE = "9A9EE708C47D8CE568D272223277FABF7C6EF6EE"
DEFAULT_SIGNATURE1 = "000000013045022100DAD508227E3ABEC13A80691EE03BF64684CD87E1669E53C6B9C21403D742B4640220516824C46E3D424A7A2BA247BB0D1821754874A91C301996AA11C39321E597DB"
DEFAULT_SIGNATURE2 = DEFAULT_SIGNATURE1


parser = argparse.ArgumentParser()
parser.add_argument('plugin_name', help="Plugin name (e.g Compound)", type=str)
parser.add_argument('contract', help="Contract address", type=str)
parser.add_argument('selector', help="Contract address", type=str)
parser.add_argument('--signature', help="Optional signature", type=str, default=DEFAULT_SIGNATURE)
parser.add_argument('--token1', help="Address of the token you wish to add", type=str)
parser.add_argument('--decimals1', help="Number of decimals of token1", type=int)
parser.add_argument('--ticker1', help="Ticker (e.g. 'DAI') of token1", type=str)
parser.add_argument('--signature1', help="Optional signature for token1", type=str, default=DEFAULT_SIGNATURE1)
parser.add_argument('--token2', help="Address of the token you wish to add", type=str)
parser.add_argument('--decimals2', help="Number of decimals of token2", type=int)
parser.add_argument('--ticker2', help="Ticker (e.g. 'DAI') of token2", type=str)
parser.add_argument('--signature2', help="Optional signature for token2", type=str, default=DEFAULT_SIGNATURE2)
args = parser.parse_args()

def generate_set_external_plugin_apdu(plugin_name, contract, selector, signature):
	plugin_name = bytes(plugin_name, 'utf-8')
	if contract.startswith("0x"):
		contract = contract[2:]
	if selector.startswith("0x"):
		selector = selector[2:]
	contract = bytearray.fromhex(contract)
	selector = bytearray.fromhex(selector)
	signature = bytearray.fromhex(signature)

	start = bytearray.fromhex("E0120000")
	totalLength = 1 + len(plugin_name) + len(contract) + len(selector) + len(signature)

	res = start + struct.pack(">B", totalLength) + struct.pack(">B", len(plugin_name)) + plugin_name + contract + selector + signature
	return hexlify(res).decode('utf-8').lower()

def test_generate_set_external():
	res = generate_set_external_plugin_apdu("Compound", "F650C3D88D12DB855B8BF7D11BE6C55A4E07DCC9A0712D683045022100E21E9D85453761784EADC85636A962F6777128911F2D385FB75B43F6F2F0D254022016F05D0FB9A068F4B4371B86", "0x9A9EE708", "C47D8CE568D272223277FABF7C6EF6EE")
	expected = "e01200006808436f6d706f756e64f650c3d88d12db855b8bf7d11be6c55a4e07dcc9a0712d683045022100e21e9d85453761784eadc85636a962f6777128911f2d385fb75b43f6f2f0d254022016f05d0fb9a068f4b4371b869a9ee708c47d8ce568d272223277fabf7c6ef6ee"
	assert(res == expected)

def generate_for_token_info(tokenInfo):
	(ticker, contract, decimals, signature) = tokenInfo
	if ticker and contract and decimals:
		if contract.startswith('0x'):
			contract = contract[2:]
		ticker_len = struct.pack(">B", len(ticker))
		ticker = bytes(ticker, 'utf-8') 
		contract = bytearray.fromhex(contract)
		decimals = struct.pack(">I", decimals)
		signature = bytearray.fromhex(signature)
		return  ticker_len + ticker + contract + decimals + signature
	else:
		return b''

def generate_provide_erc20_info(tokenInfo):
	start = bytearray.fromhex("E00A0000")
	first = generate_for_token_info(tokenInfo)
	if first:
		totalLength = len(first)
		res = start + struct.pack(">B", totalLength) + first
		return hexlify(res).decode('utf-8').lower()
	else:
		return None

def test_generate_provide_erc20_info():
	tokenInfo = ("CUSDT", "0xf650c3d88d12db855b8bf7d11be6c55a4e07dcc9", 8, args.signature1)
	res = generate_provide_erc20_info(tokenInfo)
	expected = "e00a000069054355534454f650c3d88d12db855b8bf7d11be6c55a4e07dcc900000008000000013045022100dad508227e3abec13a80691ee03bf64684cd87e1669e53c6b9c21403d742b4640220516824c46e3d424a7a2ba247bb0d1821754874a91c301996aa11c39321e597db"
	assert(res == expected)

test_generate_set_external()
test_generate_provide_erc20_info()

print(generate_set_external_plugin_apdu(args.plugin_name, args.contract, args.selector, args.signature))
tokenInfo = (args.ticker1, args.token1, args.decimals1, args.signature1)
res = generate_provide_erc20_info(tokenInfo)
if (res):
	print(res)
tokenInfo = (args.ticker2, args.token2, args.decimals2, args.signature2)
res = generate_provide_erc20_info(tokenInfo)
if (res):
	print(res)
