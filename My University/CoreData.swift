//
//  CoreData.swift
//  My University
//
//  Created by Yura Voevodin on 29.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class CoreData {
    
    /// Singleton instance
    public static let `default` = CoreData()
    
    // MARK: - Init
    
    // Can't init is singleton
    private init() {}
    
    // MARK: - Properties
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer
    }
    
    // MARK: - Methods
    
    func saveContext() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.saveContext()
    }
}
