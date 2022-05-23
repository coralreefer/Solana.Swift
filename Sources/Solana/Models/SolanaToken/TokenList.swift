import Foundation

public struct TokenTag {
    public let name: String
    public let description: String
    public init(name: String, description: String) throws {
        self.name = name
        self.description = description
    }
}
extension TokenTag: Hashable, Decodable {}

public struct TokenExtensions: Hashable, Decodable {
    public let website: String?
    public let bridgeContract: String?
}

public struct Token: Hashable, Decodable {
    public init(_tags: [String] = [], chainId: Int?, address: String, symbol: String?, name: String?, logoURI: String?, tags: [TokenTag] = [], extensions: TokenExtensions?, isNative: Bool = false) {
        self._tags = _tags
        self.chainId = chainId
        self.address = address
        self.symbol = symbol
        self.name = name
        self.logoURI = logoURI
        self.tags = tags
        self.extensions = extensions
        self.isNative = isNative
    }
    
    public init(address: String) {
        self._tags = []
        self.chainId = nil
        self.address = address
        self.symbol = nil
        self.name = nil
        self.logoURI = nil
        self.tags = []
        self.extensions = nil
        self.isNative = false
    }

    public let _tags: [String]

    public let chainId: Int?
    public let address: String
    public let symbol: String?
    public let name: String?
    public let logoURI: String?
    public var tags: [TokenTag] = []
    public let extensions: TokenExtensions?
    public private(set) var isNative = false

    enum CodingKeys: String, CodingKey {
        case chainId, address, symbol, name, logoURI, extensions, _tags = "tags"
    }
    
    public enum WrappingToken: String {
        case sollet, wormhole
    }
    
    public var wrappedBy: WrappingToken? {
        if tags.contains(where: {$0.name == "wrapped-sollet"}) {
            return .sollet
        }
        
        if tags.contains(where: {$0.name == "wrapped"}) &&
            tags.contains(where: {$0.name == "wormhole"})
        {
            return .wormhole
        }
        
        return nil
    }
    
    public static var nativeSolana: Self {
        .init(
            _tags: [],
            chainId: 101,
            address: "So11111111111111111111111111111111111111112",
            symbol: "SOL",
            name: "Solana",
//            decimals: 9,
            logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
            tags: [],
            extensions: nil,
            isNative: true
        )
    }
}
