const fs = require("fs");
const chain_to_machine = fs.openSync("chain_to_machine", "r");
const machine_to_chain = fs.openSync("machine_to_chain", "w");

let b = Buffer.alloc(8);

while(true) {
    fs.readSync(chain_to_machine, b, 0, b.length);
    let n = b.readBigInt64LE();
    console.log("Received ", n);
    n++;
    b.writeBigInt64LE(n);
    fs.writeSync(machine_to_chain, b, 0, b.length);
    console.log("Wrote ", n);
}
