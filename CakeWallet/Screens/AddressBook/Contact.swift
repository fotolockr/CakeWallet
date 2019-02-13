import CakeWalletLib
import CakeWalletCore
import SwiftyJSON

protocol JSONExportable {
    var primaryKey: String { get }
    func toJSON() -> JSON
}

protocol JSONImportable {
    init?(from json: JSON)
}

protocol JSONConvertable: JSONExportable, JSONImportable {}

struct Contact {
    let uuid: String
    let type: CryptoCurrency
    let name: String
    let address: String
    
    init(uuid: String? = nil, type: CryptoCurrency, name: String, address: String) {
        if let uuid = uuid {
            self.uuid = uuid
        } else {
            self.uuid = UUID().uuidString
        }
        
        self.type = type
        self.name = name
        self.address = address
    }
}

extension Contact: JSONConvertable {
    init?(from json: JSON) {
        guard
            let typeRaw = json["type"].string,
            let type = CryptoCurrency(from: typeRaw) else {
                return nil
        }
        
        self.uuid = json["uuid"].stringValue
        self.type = type
        self.name = json["name"].stringValue
        self.address = json["address"].stringValue
    }
    
    var primaryKey: String {
        return "uuid"
    }
    
    func toJSON() -> JSON {
        return JSON(["uuid": uuid, "name": name, "type": type.formatted(), "address": address])
    }
}

extension Contact: CellItem {
    private func color(for currency: CryptoCurrency) -> UIColor {
        switch currency {
        case .bitcoin:
            return UIColor(hex: 0xFF9900)
        case .bitcoinCash:
            return UIColor(hex: 0xee8c28)
        case .monero:
            return UIColor(hex: 0xff7519)
        case .ethereum:
            return UIColor(hex: 0x303030)
        case .liteCoin:
            return UIColor(hex: 0x88caf5)
        case .dash:
            return UIColor(hex: 0x008de4)
        }
    }
    
    func setup(cell: AddressTableCell) {
        cell.configure(name: name, type: type.formatted(), color: color(for: type))
    }
}
