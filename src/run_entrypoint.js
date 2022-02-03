"use strict";

const fs = require("fs");
const { TezosToolkit } = require("@taquito/taquito");
const { InMemorySigner } = require("@taquito/signer");

/**
 * @typedef Input
 * @type {object}
 * @property {string} rpc_node
 * @property {string} secret
 * @property {number} confirmation
 * @property {string} destination
 * @property {string} entrypoint
 * @property {object} payload
 */
/** @returns {Input} */

const input = () => {
  let x;
  for (let i = 0; i < 3; i++) {
    try {
      x = fs.readFileSync(process.stdin.fd);
      console.error("stdin: " , x);
    } catch (error) {
      if(error.code !== "EAGAIN") {
        console.error(error);
      }
    }
  }
  console.error("stdin: ", x);
  return JSON.parse(x);
};

/**
 * @typedef OutputFinished
 * @type {object}
 * @property {"applied" | "failed" | "skipped" | "backtracked" | "unknown"} status
 * @property {string} hash
 */
/**
 * @typedef OutputError
 * @type {object}
 * @property {"error"} status
 * @property {string} error
 */
/** @param {OutputFinished | OutputError} data */
const output = (data) =>
  fs.writeFileSync(process.stdout.fd, JSON.stringify(data, null, 2));

const finished = (status, hash) => output({ status, hash });
const error = (error) => {
  console.error(error);
  output({ status: "error", error: JSON.stringify(error) });
}
  

(async () => {
  const { rpc_node, secret, confirmation, destination, entrypoint, payload } =
    input();
  const args = Object.entries(payload)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([_, value]) => value);
  const Tezos = new TezosToolkit(rpc_node);
  const signer = await InMemorySigner.fromSecretKey(secret);
  Tezos.setProvider({ signer });

  const contract = await Tezos.contract.at(destination);
  const operation = await contract.methods[entrypoint](...args).send();
  await operation.confirmation(confirmation);

  finished(operation.status, operation.hash);
})().catch(error);
