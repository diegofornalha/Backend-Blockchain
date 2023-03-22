/** @format */

import { Router } from "express";
import FlowService from "../services/Flow/Flow.service";
export const walletApiRoutes = Router();

walletApiRoutes.get("/mintIntoAdmin", async (req, res) => {
  try {
    /*     const jobResponse = await FlowService.uploadMetadata(
      "123456",
      "Text for Test",
      "https://piece2.herokuapp.com/piece/previewImage/5"
    );
    console.log("Job NUMBER 1 responses", jobResponse); */

    /*     // Setup account
    const jobResponse2 = await FlowService.setupAccount("0x1ad3c2a8a0bca093");
    console.log("Job NUMBER 2 responses", jobResponse2); */

    // Mint NFT into account
    const jobResponse3 = await FlowService.mintNFT(
      "1636414956890472463",
      "0x00c0d2b7a3c4b663"
    );
    console.log("Job NUMBER 3 responses", jobResponse3);

    res.send(jobResponse3);
  } catch (error) {
    console.log(error);
    res.send(error);
  }
});
