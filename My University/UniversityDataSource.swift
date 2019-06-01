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

    // MARK: - Types

    struct Section {

        let rows: [Row]

        let kind: Kind

        enum Kind {
            case all
            case favorites
        }
    }

    struct Row {

        let kind: Kind

        enum Kind {
            case auditoriums
            case groups
            case teachers
            case favorites
        }
    }

    // MARK: - University

    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()

    var university: UniversityEntity?

    func fetch(id: Int64) {
        guard let context = viewContext else { return }
        university = UniversityEntity.fetch(id: id, context: context)
    }

    // MARK: - Sections

    var sections: [Section] = []

    func configureSections() {
        guard let university = university else { return }

        // Group, teachers and auditoriums
        var rows: [Row] = []

        if university.isKPI {
            let grops = Row(kind: .groups)
            let teachers = Row(kind: .teachers)
            rows = [grops, teachers]
        } else {
            let grops = Row(kind: .groups)
            let teachers = Row(kind: .teachers)
            let auditoriums = Row(kind: .auditoriums)
            rows = [grops, teachers, auditoriums]
        }
        sections.append(Section(rows: rows, kind: .all))

        // Favorites
        let favoritesRow = Row(kind: .favorites)
        sections.append(Section(rows: [favoritesRow], kind: .favorites))
    }
}
