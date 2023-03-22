import Pieces_4 from "../contracts/Pieces.cdc"

transaction(twitterId: UInt64, tweetText: String, recipient: Address) {
  let nftArray: [Pieces_4.NFTMetadata]
  let arrayLength: Int
  let Administrator: &Pieces_4.Administrator
  prepare (deployer: AuthAccount) {
    self.nftArray = Pieces_4.twitterIds[twitterId]!
    self.arrayLength = self.nftArray.length
            // Confirm Admin
        self.Administrator = deployer.borrow<&Pieces_4.Administrator>(from: Pieces_4.AdministratorStoragePath)
                          ?? panic("This account is not the Administrator.")
  }

  execute {
    var i = 0
    while i < self.arrayLength {
      if (self.nftArray[i].description == tweetText) {
        self.Administrator.mintNFT(twitterId: twitterId, indexNumber: i, recipient: recipient)
      }
      i = i + 1
    }
  }
}