import Pieces_4 from "../contracts/Pieces.cdc"
import MetadataViews from "../contracts/standard/MetadataViews.cdc"

pub fun main(Account: Address): [Pieces_4.NFTMetadata] {
  let collection = getAccount(Account).getCapability(Pieces_4.CollectionPublicPath)
                      .borrow<&Pieces_4.Collection{MetadataViews.ResolverCollection}>()!
  let answer: [Pieces_4.NFTMetadata] = []

  let ids = collection.getIDs()

  for id in ids {
    let resolver = collection.borrowViewResolver(id: id)
    let serialView = resolver.resolveView(Type<MetadataViews.Serial>())! as! MetadataViews.Serial
    answer.append(Pieces_4.getNFTMetadata(serialView.number)!)
  }

  return answer
}
