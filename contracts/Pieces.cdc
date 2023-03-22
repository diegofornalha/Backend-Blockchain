import MetadataViews from "./standard/MetadataViews.cdc"
import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"
import FlowToken from "./standard/FlowToken.cdc"

pub contract Pieces_4: NonFungibleToken {

	// Collection Information
	access(self) let collectionInfo: {String: AnyStruct}

	// Contract Information
	pub var nextEditionId: UInt64
	pub var totalSupply: UInt64

  // Events
  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)
	pub event Minted(id: UInt64, recipient: Address, twitterId: UInt64)

	// Paths
	pub let CollectionStoragePath: StoragePath
	pub let CollectionPublicPath: PublicPath
	pub let CollectionPrivatePath: PrivatePath
	pub let AdministratorStoragePath: StoragePath

	// Maps metadataId of NFT to NFTMetadata
	pub let twitterIds: {UInt64: [NFTMetadata]}

	// You can get a list of purchased NFTs
	// by doing `buyersList.keys`
	access(account) let buyersList: {Address: {UInt64: [UInt64]}}

	access(account) let nftStorage: @{Address: {UInt64: NFT}}

	pub struct NFTMetadata {
		pub let twitterId: UInt64
		pub let description: String
		pub let image: MetadataViews.HTTPFile
		pub let purchasers: {UInt64: Address}
		pub let metadataId: UInt64
		pub var minted: UInt64
		pub var extra: {String: AnyStruct}

		access(account) fun purchased(serial: UInt64, buyer: Address) {
			self.purchasers[serial] = buyer
		}

		access(account) fun updateMinted() {
			self.minted = self.minted + 1
		}

		init(_twitterId: UInt64, _description: String, _image: MetadataViews.HTTPFile, _extra: {String: AnyStruct}) {
			self.metadataId = _twitterId
			self.twitterId = _twitterId
			self.description = _description
			self.image = _image
			self.extra = _extra
			self.minted = 0
			self.purchasers = {}
		}
	}

	pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
		pub let id: UInt64
		// The 'metadataId' is what maps this NFT to its 'NFTMetadata'
		pub let twitterId: UInt64
		pub let serial: UInt64
		pub let indexNumber: Int
		pub let originalMinter: Address

		pub fun getMetadata(): NFTMetadata {
			return Pieces_4.getNFTMetadata(self.twitterId, self.indexNumber )!
		}

		pub fun getViews(): [Type] {
			return [
				Type<MetadataViews.Display>(),
				Type<MetadataViews.ExternalURL>(),
				Type<MetadataViews.NFTCollectionData>(),
				Type<MetadataViews.NFTCollectionDisplay>(),
				Type<MetadataViews.Royalties>(),
				Type<MetadataViews.Serial>(),
				Type<MetadataViews.NFTView>()
			]
		}

		pub fun resolveView(_ view: Type): AnyStruct? {
			switch view {
				case Type<MetadataViews.Display>():
					let metadata = self.getMetadata()
					return MetadataViews.Display(
						twitterId: metadata.twitterId.toString(),
						description: metadata.description,
						thumbnail: metadata.image
					)
				case Type<MetadataViews.NFTCollectionData>():
					return MetadataViews.NFTCollectionData(
						storagePath: Pieces_4.CollectionStoragePath,
						publicPath: Pieces_4.CollectionPublicPath,
						providerPath: Pieces_4.CollectionPrivatePath,
						publicCollection: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						publicLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						providerLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection, NonFungibleToken.Provider}>(),
						createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
								return <- Pieces_4.createEmptyCollection()
						})
					)
        case Type<MetadataViews.ExternalURL>():
          return MetadataViews.ExternalURL("https://hackathon.flow.com/")

					// Collection Display on FlowView
        case Type<MetadataViews.NFTCollectionDisplay>():

          let media = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
            url: "https://devfolio.co/_next/image?url=https%3A%2F%2Fassets.devfolio.co%2Fhackathons%2Ffa27cfa336754d41aa5ce25acea7815d%2Fprojects%2Ffc806c2296be4507b57881210984dd3e%2F89346bf7-8463-48d3-aed4-b27479001417.jpeg&w=1440&q=75"
            ),
            mediaType: "image"
          )

      		return MetadataViews.NFTCollectionDisplay(
          	name: Pieces_4.getCollectionAttribute(key: "name") as! String,
          	description: Pieces_4.getCollectionAttribute(key: "description") as! String,
          	externalURL: MetadataViews.ExternalURL("https://hackathon.flow.com/"),
          	squareImage: media,
          	bannerImage: media,
          	socials: {"Website": MetadataViews.ExternalURL("https://frontend-react-git-testing-piece.vercel.app/")}
        	)
        case Type<MetadataViews.Royalties>():
          return MetadataViews.Royalties([
            MetadataViews.Royalty( // This is my own Blotco address
              recepient: getAccount(self.originalMinter).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver),
              cut: 0.05, // 5% royalty on secondary sales
              description: "The Owner of the original Tweet gets 5% of every secondary sale."
            )
          ])
				case Type<MetadataViews.Serial>():
					return MetadataViews.Serial(
						self.serial
					)
					case Type<MetadataViews.Traits>():
					return MetadataViews.dictToTraits(dict: self.getMetadata().extra, excludedNames: nil)
				case Type<MetadataViews.NFTView>():
					return MetadataViews.NFTView(
						id: self.id,
						uuid: self.uuid,
						display: self.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display?,
						externalURL: self.resolveView(Type<MetadataViews.ExternalURL>()) as! MetadataViews.ExternalURL?,
						collectionData: self.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?,
						collectionDisplay: self.resolveView(Type<MetadataViews.NFTCollectionDisplay>()) as! MetadataViews.NFTCollectionDisplay?,
						royalties: self.resolveView(Type<MetadataViews.Royalties>()) as! MetadataViews.Royalties?,
						traits: self.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits?
					)
			}
			return nil
		}

		init(_twitterId: UInt64, _indexNumber: Int, _recipient: Address) {
			pre {
				Pieces_4.twitterIds[_twitterId] != nil:
					"This NFT does not exist in this collection."
			}
			// Assign serial number to the NFT based on the number of minted NFTs
			let _serial = Pieces_4.getNFTMetadata(_twitterId, _indexNumber)!.minted
			self.id = self.uuid
			self.twitterId = _twitterId
			self.serial = _serial
			self.indexNumber = _indexNumber
			self.originalMinter = _recipient

			// Update the buyers list so we keep track of who is purchasing
			if let buyersRef = &Pieces_4.buyersList[_recipient] as &{UInt64: [UInt64]}? {
				if let metadataIdMap = &buyersRef[_twitterId] as &[UInt64]? {
					metadataIdMap.append(_serial)
				} else {
					buyersRef[_twitterId] = [_serial]
				}
			} else {
				Pieces_4.buyersList[_recipient] = {_twitterId: [_serial]}
			}

			let metadataRef = (&Pieces_4.twitterIds[_twitterId]![_indexNumber] as &NFTMetadata?)!
			// Update who bought this serial inside NFTMetadata
			metadataRef.purchased(serial: _serial, buyer: _recipient)
			// Update the total supply of this MetadataId by 1
			metadataRef.updateMinted()
			// Update Pieces_4 collection NFTs count
			Pieces_4.totalSupply = Pieces_4.totalSupply + 1

			emit Minted(id: self.id, recipient: _recipient, twitterId: _twitterId)
		}
	}

	pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {

		pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

		// Withdraw removes an NFT from the collection and moves it to the caller(for Trading)
		pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
			let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

			emit Withdraw(id: token.id, from: self.owner?.address)

			return <-token
		}

		// Deposit takes a NFT and adds it to the collections dictionary
		// and adds the ID to the id array
		pub fun deposit(token: @NonFungibleToken.NFT) {
			let token <- token as! @NFT

			let id: UInt64 = token.id

			// Add the new token to the dictionary
			self.ownedNFTs[id] <-! token

			emit Deposit(id: id, to: self.owner?.address)
		}

		// GetIDs returns an array of the IDs that are in the collection
		pub fun getIDs(): [UInt64] {
			return self.ownedNFTs.keys
		}

		// BorrowNFT gets a reference to an NFT in the collection
		pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
			return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
		}

		pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
			let token = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
			let nft = token as! &NFT
			return nft as &AnyResource{MetadataViews.Resolver}
		}

		pub fun claim() {
			if let storage = &Pieces_4.nftStorage[self.owner!.address] as &{UInt64: NFT}? {
				for id in storage.keys {
					self.deposit(token: <- storage.remove(key: id)!)
				}
			}
		}

		init () {
			self.ownedNFTs <- {}
		}

		destroy() {
			destroy self.ownedNFTs
		}
	}

	pub resource Administrator {
	// Function to upload the Metadata to the contract.
		pub fun createNFTMetadata(
			twitterId: UInt64,
			description: String,
			url: String
			) {

				if Pieces_4.twitterIds[twitterId] == nil {
					Pieces_4.twitterIds[twitterId] = []
				}

				Pieces_4.twitterIds[twitterId]?.append(NFTMetadata(
					_twitterId: twitterId,
					_description: description,
					_image: MetadataViews.HTTPFile(
						url: url,
					),
					_extra: {
						"TwitterId": twitterId,
						"Tweet": description}
				))
		}

		// mintNFT mints a new NFT and deposits
		// it in the recipients collection
		pub fun mintNFT(twitterId: UInt64, indexNumber: Int, recipient: Address) {

			let nft <- create NFT(_twitterId: twitterId, _indexNumber: indexNumber, _recipient: recipient)

			if let recipientCollection = getAccount(recipient).getCapability(Pieces_4.CollectionPublicPath).borrow<&Pieces_4.Collection{NonFungibleToken.CollectionPublic}>() {
				recipientCollection.deposit(token: <- nft)
			} else {
				if let storage = &Pieces_4.nftStorage[recipient] as &{UInt64: NFT}? {
					storage[nft.id] <-! nft
				} else {
					Pieces_4.nftStorage[recipient] <-! {nft.id: <- nft}
				}
			}
		}

		// create a new Administrator resource
		pub fun createAdmin(): @Administrator {
			return <- create Administrator()
		}

		// change pieces_4 of collection info
		pub fun changeField(key: String, value: AnyStruct) {
			Pieces_4.collectionInfo[key] = value
		}
	}

	// public function that anyone can call to create a new empty collection
	pub fun createEmptyCollection(): @NonFungibleToken.Collection {
		return <- create Collection()
	}

	// Get information about a NFTMetadata
	pub fun getNFTMetadata(_ twitterId: UInt64,_ indexNumber: Int): NFTMetadata? {
		return self.twitterIds[twitterId]![indexNumber]
	}

	pub fun getNFTMetadatas(twitterId: UInt64): [NFTMetadata]? {
		return self.twitterIds[twitterId]
	}

	pub fun getbuyersList(): {Address: {UInt64: [UInt64]}} {
		return self.buyersList
	}

	pub fun getCollectionInfo(): {String: AnyStruct} {
		let collectionInfo = self.collectionInfo
		collectionInfo["twitterIds"] = self.twitterIds
		collectionInfo["buyersList"] = self.buyersList
		collectionInfo["totalSupply"] = self.totalSupply
		collectionInfo["version"] = 1
		return collectionInfo
	}

	pub fun getCollectionAttribute(key: String): AnyStruct {
		return self.collectionInfo[key] ?? panic(key.concat(" is not an attribute in this collection."))
	}

	init() {
		// Collection Info
		self.collectionInfo = {}
		self.collectionInfo["name"] = "Pieces_4"
		self.collectionInfo["description"] = "Inmortalize Your Tweets!"
		self.collectionInfo["image"] = MetadataViews.IPFSFile(
				cid: "bafybeihkurbbjxq5v7ag62ahvatrvizmv4tqebzzm26nz6ils4nxgh5ko4",
				path: "/Alex1.png"
		)
		self.collectionInfo["bannerImage"] = MetadataViews.IPFSFile(
				cid: "bafybeihkurbbjxq5v7ag62ahvatrvizmv4tqebzzm26nz6ils4nxgh5ko4",
				path: "/Alex1.png"
		)
    self.collectionInfo["ipfsCID"] = "bafybeihkurbbjxq5v7ag62ahvatrvizmv4tqebzzm26nz6ils4nxgh5ko4"
    self.collectionInfo["dateCreated"] = getCurrentBlock().timestamp
    self.collectionInfo["profit"] = 0.0
		self.collectionInfo["nftRoyalty"] =  MetadataViews.Royalty(
          recepient: getAccount(self.account.address).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver),
          cut: 0.5,
          description: "This is a royalty cut on primary sales."
        )
		self.collectionInfo["socials"] = {"Website": MetadataViews.ExternalURL("https://frontend-react-git-testing-piece.vercel.app/")}
		self.nextEditionId = 0
		self.totalSupply = 0
		self.twitterIds = {}
		self.buyersList = {}
		self.nftStorage <- {}

		// Set the named paths
		self.CollectionStoragePath = /storage/Pieces_4Collection
		self.CollectionPublicPath = /public/Pieces_4Collection
		self.CollectionPrivatePath = /private/Pieces_4Collection
		self.AdministratorStoragePath = /storage/Pieces_4Administrator

		// Create a Collection resource and save it to storage
		let collection <- create Collection()
		self.account.save(<- collection, to: self.CollectionStoragePath)

		// Create a public capability for the collection
		self.account.link<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
			self.CollectionPublicPath,
			target: self.CollectionStoragePath
		)

		// Create a Administrator resource and save it to storage
		let administrator <- create Administrator()
		self.account.save(<- administrator, to: self.AdministratorStoragePath)

		emit ContractInitialized()
	}
}
