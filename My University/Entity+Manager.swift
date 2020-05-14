//
//  Entity+Manager.swift
//  My University
//
//  Created by Yura Voevodin on 13.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Entity {
    
    class Manager {
        
        /// Singleton instance
        public static let shared = Entity.Manager()
        
        // MARK: - Init
        
        // Can't init is singleton
        private init() {
            load()
        }
        
        // MARK: - Last opened
        
        private(set) var lastOpened: Entity?
        
        public func update(with entity: Entity) {
            self.lastOpened = entity
            save(entity)
        }
        
        public func deleteLastOpened() {
            UserDefaults.standard.removeObject(forKey: lastOpenedKey)
        }
        
        private func save(_ entity: Entity) {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(entity) {
                UserDefaults.standard.set(encoded, forKey: lastOpenedKey)
                UserDefaults.standard.synchronize()
            }
        }
        
        private func load() {
            let defaults = UserDefaults.standard
            if let data = defaults.object(forKey: lastOpenedKey) as? Data {
                let decoder = JSONDecoder()
                if let object = try? decoder.decode(Entity.self, from: data) {
                    self.lastOpened = object
                }
            }
        }
        
        private var lastOpenedKey: String {
            return "\(Bundle.identifier).last-opened-entity"
        }
    }
}
