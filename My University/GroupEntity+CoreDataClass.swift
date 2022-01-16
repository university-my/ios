//
//  GroupEntity+CoreDataClass.swift
//  Schedule
//
//  Created by Yura Voevodin on 12.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(GroupEntity)
public class GroupEntity: NSManagedObject {
    
}

// MARK: - CoreDataEntityProtocol

extension GroupEntity: CoreDataEntityProtocol {
    
    func shareURL(for date: Date) -> URL? {
        guard let parameters = pageParameters(with: date) else {
            return nil
        }
        return Group.Endpoints.websitePage(from: parameters).url
    }
}

// MARK: - StructRepresentable

extension GroupEntity: StructRepresentable {
    
    func asStruct() -> EntityRepresentable? {
        guard let name = name else { return nil }
        guard let slug = slug else { return nil }
        return Group(id: id, isFavorite: isFavorite, name: name, slug: slug, uuid: uuid?.uuidString)
    }
}

extension GroupEntity: CoreDataFetchable {}
