import Foundation
import CakeWalletLib
import CWMonero

final class NodesList: Collection {
    static let shared: NodesList = NodesList()
    
    private static func load() -> [[String: Any]] {
        if !FileManager.default.fileExists(atPath: url.path) {
           try! copyOriginToDocuments()
        }
        
        guard
            let nodesData = try? Data(contentsOf: url),
            let propertyList = try? PropertyListSerialization.propertyList(from: nodesData, options: [], format: nil),
            let nodesDirs = propertyList as? [[String: Any]] else {
                return []
        }
        
        return nodesDirs
    }
    
    private static func copyOriginToDocuments() throws {
        try FileManager.default.copyItem(at: originalNodesListUrl, to: url)
    }
    
    static let originalNodesListUrl = Bundle.main.url(forResource: "NodesList", withExtension: "plist")!
    static var url: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("NodesList.plist")
    }
    private var content: [[String: Any]] = []
    var values: [NodeDescription] {
        return content.map { node -> NodeDescription? in
            if let uri = node["uri"] as? String {
                //fixme
                return MoneroNodeDescription(
                    uri: uri,
                    login: node["login"] as? String ?? "",
                    password: node["password"] as? String ?? ""
                )
            } else {
                return nil
            }
            }.compactMap({ $0 })
    }
    
    var count: Int {
        return content.count
    }
    
    var startIndex: Int {
        return content.startIndex
    }
    
    var endIndex: Int {
        return content.endIndex
    }
    
    subscript(position: Int) -> NodeDescription {
        //fixme
        return MoneroNodeDescription(
            uri: content[position]["uri"] as? String ?? "",
            login: content[position]["login"] as? String ?? "",
            password: content[position]["password"] as? String ?? "")
    }
    
    private init() {
        content = NodesList.load()
    }
    
    func index(after i: Int) -> Int {
        return content.index(after: i)
    }
    
    func add(node: NodeDescription) throws {
        content.append(node.toDictionary())
        try save()
    }
    
    func remove(at index: Int) throws {
        self.content.remove(at: index)
        let content = self.content as NSArray
        if #available(iOS 11.0, *) {
            try content.write(to: NodesList.url)
        } else {
            
            // Fallback on earlier versions
        }
    }
    
    func reset() throws {
        if NodesList.originalNodesListUrl != NodesList.url {
            try FileManager.default.removeItem(at: NodesList.url)
            try FileManager.default.copyItem(at: NodesList.originalNodesListUrl, to: NodesList.url)
        }
        
        content = NodesList.load()
    }
    
    func save() throws {
        let content = self.content as NSArray
        if #available(iOS 11.0, *) {
            try content.write(to: NodesList.url)
        } else {
            // Fallback on earlier versions
        }
    }
}

extension NodeDescription {
    func toDictionary() -> [String: Any] {
        var dir = [String: Any]()
        
        if !login.isEmpty {
            dir["login"] = login
        }
        
        if !password.isEmpty {
            dir["password"] = password
        }
        
        dir["uri"] = uri
        return dir
    }
}
