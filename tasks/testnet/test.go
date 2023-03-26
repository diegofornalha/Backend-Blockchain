package main

import (
	"fmt"
	//if you imports this with .  you do not have to repeat overflow everywhere
	. "github.com/bjartek/overflow"
)

func main() {
	o := Overflow(

		WithGlobalPrintOptions(),
		WithNetwork("testnet"),
	)

	fmt.Println("Interacting with the Pieces contract on Testnet")
	fmt.Println("Press any key to continue")
	fmt.Scanln()

	// These functions are for fetching data from the testnet

	o.Script("getCollectionInfo").Print()
}
