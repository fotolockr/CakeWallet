import SwiftyJSON

class AddressBook {
    static let shared: AddressBook = AddressBook()
    
    private static let name = "address_book.json"
    
    private static var url: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    }
    
    private static func load() -> JSON {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSON(data: data) else {
                return JSON()
        }
        
        return json
    }
    
    private var json: JSON
    
    private init() {
        json = AddressBook.load()
    }
    
    func all() -> [Contact] {
        return json.array?.map({ json -> Contact? in
            return Contact(from: json)
        }).compactMap({ $0 }) ?? []
    }
    
    func addOrUpdate(contact: Contact) throws {
        let isExist = json.arrayValue
            .filter({ $0[contact.primaryKey].stringValue == contact.uuid })
            .first != nil
        let updatedJson: JSON
        
        if isExist {
            updatedJson = JSON(json.arrayValue.map({ json -> JSON in
                let currentUuid = json[contact.primaryKey].stringValue
                
                if currentUuid == contact.uuid {
                    return contact.toJSON()
                }
                
                return json
            }))
        } else {
            let array = json.arrayValue + [contact.toJSON()]
            updatedJson = JSON(array)
        }
        
        try save(json: updatedJson)
        json = updatedJson
    }
    
    func delete(for uuid: String) throws {
        let updatedJson = JSON(json.arrayValue.filter({ json -> Bool in
            let contactUuid = json["uuid"].stringValue
            
            if contactUuid != uuid {
                return true
            }
            
            return false
        }))
        
        try save(json: updatedJson)
        json = updatedJson
    }
    
    private func save(json: JSON) throws {
        try json.rawData().write(to: AddressBook.url)
    }
}
