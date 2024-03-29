package main

import (
	"fmt"
	//if you imports this with .  you do not have to repeat overflow everywhere
	. "github.com/bjartek/overflow"
	"github.com/fatih/color"
)

func main() {

	//start an in memory emulator by default
	o := Overflow(
		WithGlobalPrintOptions(),
	)

	fmt.Println("Testing Contract")
	fmt.Println("Press any key to continue")
	fmt.Scanln()

	// Record Metadata to the contract
	color.Red("Should be able to upload metadata to the contract the Collection")
	o.Tx(
		"uploadMetadata",
		WithSigner("account"),
		WithArg("_twitterId", `12345`),
		WithArg("_description", `"I bet that Argentina will win the 2022 World Cup"`),
		WithArg("_url", `"https://testnet.flowview.app/_next/image?url=https%3A%2F%2Fpiece2.herokuapp.com%2Fpiece%2FpreviewImage%2F22&w=1200&q=75"`),
	)
	color.Green("-----------------------------PASSED---------------------")

	/* 	// Get Metadatas recorded in the contract
	   	color.Red("Should be able to fetch metadatas from the contract")
	   	o.Script("getNFTsMetadatas")
	   	color.Green("-----------------------------PASSED---------------------") */

	// Setup Bob's account to hold a Pieces NFT
	color.Red("Should be able to setup Bob's account with Pieces collection path")
	o.Tx("setupAccount",
		WithSigner("alice"),
	)
	color.Green("-----------------------------PASSED---------------------")

	// Admin mints an NFT
	color.Red("Admin should be able to mint an NFT")
	o.Tx("mintNFT",
		WithSigner("account"),
		WithArg("twitterId", "12345"),
		WithArg("tweetText", `"I bet that Argentina will win the 2022 World Cup"`),
		WithArg("recipient", "alice"),
	)
	color.Green("-----------------------------PASSED---------------------")

	// Get Metadatas recorded in the contract after minting
	// (supply should increase)
	/* 			color.Red("Should be able to fetch metadatas from the contract")
	   			o.Script("getNFTSupply",
	   				WithArg("MetadataId", "0"),
	   			)
	   			color.Green("-----------------------------PASSED---------------------")

	   			// Get all the Pieces NFTs owned by this account
	   			color.Red("Should be able to fetch all the Pieces NFTs owned by this account")
	   			o.Script("getOwnedNFTs",
	   				WithArg("Account", "bob"),
	   			)
	   			color.Green("-----------------------------PASSED---------------------") */

}
