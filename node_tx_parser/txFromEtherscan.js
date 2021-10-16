import ethers from "ethers"
const RLP = ethers.utils.RLP

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

	let decoded = RLP.decode("0x" + rawTx);
	if (txType != "") {
		decoded = decoded.slice(0, decoded.length - 3); // remove v, r, s
	} else {
		decoded[decoded.length - 1] = "0x"; // empty
		decoded[decoded.length - 2] = "0x"; // empty
		decoded[decoded.length - 3] = "0x01"; // chainID 1
	}

	// Encode back the data, drop the '0x' prefix
	let encoded = RLP.encode(decoded).slice(2);

	// Don't forget to prepend the txtype
	return txType + encoded;
}

export function getHexLen(str) {
	const len = str.length / 2
	if (len.toString(16) < 10)
		return '0' + len.toString(16)
	return len.toString(16)
}

export default txFromEtherscan;