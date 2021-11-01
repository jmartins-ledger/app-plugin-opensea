#! /usr/bin/env node

import txFromEtherscan, { getHexLen } from "./txFromEtherscan.js"

if (!process.argv[2]) {
	console.log("plz enter a raw Tx.")
	process.exit(1)
}

const inputedTx = process.argv[2].trim()
const APDU_MAX = 150

/* Prepend the raw data */
const parsed = '048000002C8000003C8000000000000000' + txFromEtherscan(inputedTx).toUpperCase()
let len = parsed.length / 2
if (len > APDU_MAX) len = APDU_MAX

/* Split into 300 byte chunks */
const splited = parsed.match(/.{1,300}/g)

let res = []
splited.forEach((line, index) => {
	/* First */
	if (index === 0)
		res.push(`E0040000${len.toString(16)}${line}`)
	/* Last */
	else if (index === (splited.length - 1))
		res.push(`E0048000${getHexLen(line)}${line}`)
	/* Between */
	else res.push(`E004800096${line}`)
})

/* Output result */
res.forEach(elem => console.log(elem))
console.log('+')
