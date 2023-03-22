import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Pieces_4 from "../contracts/Pieces.cdc"
import MetadataViews from "../contracts/standard/MetadataViews.cdc"

// This transaction configures an account to hold a Pieces_4 NFT.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&Pieces_4.Collection>(from: Pieces_4.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Pieces_4.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: Pieces_4.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Pieces_4.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(Pieces_4.CollectionPublicPath, target: Pieces_4.CollectionStoragePath)
        }
    }
}
