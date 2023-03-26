import Pieces_4 from "../contracts/Pieces.cdc"

pub fun main(MetadataId: UInt64): UInt64? {
  return Pieces_4.getNFTMetadata(MetadataId)?.minted
}