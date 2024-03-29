//
//  RecordsDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 27.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit
import CoreData

class RecordsDataSource {
    
    // MARK: - Sections
    
    struct Section {
        
        enum Kind {
            case noRecords
            case records(records: [Record], title: String)
        }
        
        var kind: Kind
        
        var title: String? {
            switch kind {
            case .noRecords:
                return nil
            case .records(_, let title):
                return title
            }
        }
    }
    
    var sections: [Section] = []
    
    // MARK: - Core Data
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer
    }
    
    /// `[RecordEntity]` to `[Section]`
    func buildRecordsSections(from fetchedResultsController: NSFetchedResultsController<RecordEntity>?) -> [Section] {
        var sections: [Section] = []
        guard let controller = fetchedResultsController else { return [] }
        
        controller.sections?.forEach({ (section) in
            if let fetchedRecords = section.objects as? [RecordEntity] {
                
                // Title
                let title = sectionName(from: fetchedRecords.first)
                
                // Records
                let records = fetchedRecords.toStructs()
                
                let section = Section(kind: .records(records: records, title: title))
                sections.append(section)
            }
        })
        return sections
    }
    
    private func sectionName(from record: RecordEntity?) -> String {
        var sectionName = ""
        if let name = record?.pairName {
            sectionName = name
        }
        if let time = record?.time {
            sectionName += " (\(time))"
        }
        return sectionName
    }
}
