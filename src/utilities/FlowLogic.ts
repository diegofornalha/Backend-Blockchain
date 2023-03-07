/** @format */

import {
  createAccount,
  setupAccount,
  uploadMetadata,
  fetchAccount,
  mintNFT,
} from "../services/walletAPI.service";

export const FlowLogicHandler = async (TwitterId: number, Text: string) => {
  /* Check the account doesn't already exist
  - call the database with the TwitterID as param
  - if it returns an existing object, then
  - skip to create metadata
  */

  // Create a wallet for the Id
  const account = await createAccount();
  console.log("Account Address", account.address);
  // Create metadataId
  const jobResponse = await uploadMetadata(
    TwitterId,
    Text,
    "/Alex1.png",
    "ipfs://bafybeihkurbbjxq5v7ag62ahvatrvizmv4tqebzzm26nz6ils4nxgh5ko4"
  );
  console.log("Job NUMBER 1 responses", jobResponse);

  // Setup account
  const jobResponse2 = await setupAccount(account.address);
  console.log("Job NUMBER 2 responses", jobResponse2);

  // Mint NFT into account
  const jobResponse3 = await mintNFT(TwitterId, account.address);
  console.log("Job NUMBER 3 responses", jobResponse3);

  return jobResponse3;
};
