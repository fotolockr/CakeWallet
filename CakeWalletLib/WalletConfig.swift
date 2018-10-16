import Foundation

public final class WalletConfig: Encodable, Decodable {
    enum CodingKeys: String, CodingKey {
        case isRecovery
        case date
    }
    
    public static func load(from url: URL) throws -> WalletConfig {
        let jsonDecoder = JSONDecoder()
        let jsonData = try Data(contentsOf: url)
        return try jsonDecoder.decode(WalletConfig.self, from: jsonData)
    }
    
    public private(set) var isRecovery: Bool
    public let date: Date
    public var url: URL?
    
    public init(isRecovery: Bool, date: Date, url: URL? = nil) {
        self.isRecovery = isRecovery
        self.date = date
        self.url = url
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRecovery = try values.decode(Bool.self, forKey: .isRecovery)
        date = try values.decode(Date.self, forKey: .date)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRecovery, forKey: .isRecovery)
        try container.encode(date, forKey: .date)
    }
    
    public func update(isRecovery: Bool) throws {
        self.isRecovery = isRecovery
        try save()
    }
    
    public func save() throws {
        guard let url = url else { return }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        try jsonData.write(to: url)
    }
}
