//
//  VenderIDManager.swift
//  WatchWithIosApp Watch App
//
//  Created by USER on 8/23/24.
//

import Foundation

class UniqueIDManager {
    static let shared = UniqueIDManager()
    private let uniqueIDKey = "com.kodomo"
    
    private init() {}
    
    func getUniqueID() -> String {
        if let savedID = UserDefaults.standard.string(forKey: uniqueIDKey) {
            return savedID
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: uniqueIDKey)
            return newID
        }
    }

}
