//
//  ClassroomEntity+CoreDataClass.swift
//  My University
//
//  Created by Yura Voevodin on 12.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClassroomEntity)
public class ClassroomEntity: NSManagedObject {
    
}

// MARK: - CoreDataEntityProtocol

extension ClassroomEntity: CoreDataEntityProtocol {
    
    func shareURL(for date: Date) -> URL? {
        guard let parameters = pageParameters(with: date) else {
            return nil
        }
        return Classroom.Endpoints.websitePage(from: parameters).url
    }
}

// MARK: - StructRepresentable

extension ClassroomEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        guard let name = name else { return nil }
        guard let slug = slug else { return nil }
        return Classroom(id: id, isFavorite: isFavorite, name: name, slug: slug, uuid: uuid?.uuidString)
    }
}

extension ClassroomEntity: CoreDataFetchable {}
