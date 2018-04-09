//
//  NodesList.swift
//  CakeWallet
//
//  Created by Cake Technologies on 07.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

final class NodesList: Collection {
    static let shared = NodesList()
    private static func load() -> [[String: Any]] {
        guard
            let nodesData = try? Data(contentsOf: NodesList.url),
            let propertyList = try? PropertyListSerialization.propertyList(from: nodesData, options: [], format: nil),
            let nodesDirs = propertyList as? [[String: Any]] else {
                return []
        }
        
        return nodesDirs
    }
    
    static let originalNodesListUrl = Bundle.main.url(forResource: "NodesList", withExtension: "plist")!
    static var url: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("NodesList.plist")
            ?? originalNodesListUrl
    }
    private var content: [[String: Any]] = []
    var values: [ConnectionSettings] {
        return content.map { node -> ConnectionSettings? in
            if let uri = node["uri"] as? String {
                return ConnectionSettings(
                    uri: uri,
                    login: node["login"] as? String ?? "",
                    password: node["password"] as? String ?? "")
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
    
    subscript(position: Int) -> ConnectionSettings {
        return ConnectionSettings(
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
    
    func addNode(settings: ConnectionSettings) throws {
        content.append(settings.toDictionary())
        try save()
    }
    
    func remove(at index: Int) throws {
        self.content.remove(at: index)
        let content = self.content as NSArray
        try content.write(to: NodesList.url)
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
        try content.write(to: NodesList.url)
    }
}
