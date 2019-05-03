//
//  UniversityDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 5/3/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class UniversityDataSource: NSObject {

    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()

    var university: UniversityEntity?

    func fetch(id: Int64) {
        guard let context = viewContext else { return }
        university = UniversityEntity.fetch(id: id, context: context)
    }
}
