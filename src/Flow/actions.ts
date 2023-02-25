/** @format */

//@ts-ignore
import * as fcl from "@onflow/fcl";
//import t from "@onflow/types";
import "./config";
import { Buffer } from "buffer/";
import { authorizationFunction } from "./helpers/authorization";

fcl.config().put("accessNode.api", "https://rest-testnet.onflow.org");

// This function validates the transaction
const validateTransaction = (transactionDetails: any) => {
  console.log(transactionDetails);
  if (transactionDetails.status === 4 && transactionDetails.statusCode === 0) {
    console.log("Successful");
    return "Successful";
  } else {
    return transactionDetails;
  }
};
// This is the function that pays for the transaction and fees
const proposer = authorizationFunction;
const payer = authorizationFunction;
const authorizations = [authorizationFunction];

// ///////////////
// // Cadence code
// ///////////////

// Lifecycle FCL Auth functions
export const unauthenticate = () => fcl.unauthenticate();
export const logIn = async () => await fcl.logIn();
export const signUp = () => fcl.signUp();
export const currentUser = () => fcl.currentUser();

// // Pieces NFTs Scripts
import { getNFTsMetadata as getNFTsMetadataScript } from "./Scripts/getNFTsMetadata";
import { getMintedNFTs as getMintedNFTsScript } from "./Scripts/getNFTSupply";
import { getOwnedNFTs as getOwnedNFTsScript } from "./Scripts/getOwnedNFTs";

// Pieces NFTs Transactions
import { uploadMetadata as uploadMetadataTransaction } from "./Transactions/uploadMetadata";
import { setupAccount as setupAccountTransaction } from "./Transactions/setupAccount";
import { mintNFT as mintNFTTransaction } from "./Transactions/mintNFT";

// // ****** Transactions Functions ****** //

// Upload Text metadata to Pieces collection
export const uploadMetadata = async (
  name: String,
  description: String,
  image: String,
  extra: { String: String },
  ipfsCID: String
) => {
  // Args
  const args = (arg, t) => [
    arg(name, t.String),
    arg(description, t.String),
    arg(image, t.String),
    arg(extra, t.Dictionary({ key: t.String, value: t.String })),
    arg(ipfsCID, t.String),
  ];
  return new Promise(async (resolve, reject) => {
    try {
      const transactionId = await fcl.mutate({
        cadence: uploadMetadataTransaction(),
        args,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        limit: 500,
      });
      const transaction = validateTransaction(
        await fcl.tx(transactionId).onceSealed()
      );
      return transaction;
    } catch (e) {
      console.log(e);
      reject(false);
    }
  });
};

// Setup an account to mint Pieces NFTs
export const setupAccount = async () => {
  return new Promise(async (resolve, reject) => {
    try {
      const transactionId = await fcl.mutate({
        cadence: setupAccountTransaction(),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        limit: 500,
      });
      const transaction = validateTransaction(
        await fcl.tx(transactionId).onceSealed()
      );
      return transaction;
    } catch (e) {
      console.log(e);
      reject(false);
    }
  });
};

// Mint a Pieces NFT
export const mintNFT = async (metadataId: String) => {
  // Args
  const args = (arg, t) => [arg(metadataId, t.String)];
  return new Promise(async (resolve, reject) => {
    try {
      const transactionId = await fcl.mutate({
        cadence: mintNFTTransaction(),
        args,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        limit: 500,
      });
      const transaction = validateTransaction(
        await fcl.tx(transactionId).onceSealed()
      );
      return transaction;
    } catch (e) {
      console.log(e);
      reject(false);
    }
  });
};

// // ****** Script Functions ****** //

// Get a list of NFTs Metadatas
export const getNFTsMetadata = async () => {
  try {
    const response = await fcl.query({
      cadence: getNFTsMetadataScript(),
      args: (arg: any, t: any) => [],
    });
    console.log(response);
    return response;
  } catch (e) {
    console.log(e);
  }
};

// Get number of minted NFTs for a specific metadata
export const getMintedNFTs = async (MetadataId: String) => {
  try {
    const response = await fcl.query({
      cadence: getMintedNFTsScript(),
      args: (arg: any, t: any) => [arg(MetadataId, t.String)],
    });
    console.log(response);
    return response;
  } catch (e) {
    console.log(e);
  }
};

// Get a list of owned NFTs for an address
export const getOwnedNFTs = async (Account: String) => {
  try {
    const response = await fcl.query({
      cadence: getOwnedNFTsScript(),
      args: (arg: any, t: any) => [arg(Account, t.Address)],
    });
    console.log(response);
    return response;
  } catch (e) {
    console.log(e);
  }
};
