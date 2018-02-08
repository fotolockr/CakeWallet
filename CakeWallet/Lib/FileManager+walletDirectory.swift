//
//  FileManager+walletDirectory.swift
//  Wallet
//
//  Created by Cake Technologies 09.11.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

enum FileManagerError: Error {
    case cannotFindWalletDir
}

extension FileManager {
    var walletDirectory: URL? {
        return self.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func createWalletDirectory(for name: String) throws -> URL {
        guard var url  = walletDirectory else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        url.appendPathComponent(name, isDirectory: true)
        
        var isDir: ObjCBool = true
        
        if !fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue {
            try createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    func walletDirectory(for name: String) throws -> URL {
        guard var url  = walletDirectory else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        url.appendPathComponent(name, isDirectory: true)
        
        var isDir: ObjCBool = true
        
        guard fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue  else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        return url
    }
}
