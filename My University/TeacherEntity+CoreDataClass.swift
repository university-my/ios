//
//  TeacherEntity+CoreDataClass.swift
//  My University
//
//  Created by Yura Voevodin on 2/14/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TeacherEntity)
public class TeacherEntity: NSManagedObject {
    
}

// MARK: - CoreDataEntityProtocol

extension TeacherEntity: CoreDataEntityProtocol {
    
    var favorite: Bool {
        get {
            return isFavorite
        }
        set {
            isFavorite = newValue
        }
    }
    
    func shareURL(for date: Date) -> URL? {
        guard let parameters = pageParameters(with: date) else {
            return nil
        }
        return Teacher.Endpoints.websitePage(from: parameters).url
    }
}

// MARK: - StructRepresentable

extension TeacherEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        Teacher(
            id: id,
            isFavorite: isFavorite,
            name: name ?? "",
            slug: slug ?? ""
        )
    }
}

extension TeacherEntity: CoreDataFetchable {}
