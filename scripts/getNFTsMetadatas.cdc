import Pieces_4 from "../contracts/Pieces.cdc"

pub fun main(): {UInt64: Pieces_1.NFTMetadata} {
  return Pieces_4.getNFTMetadatas()
}