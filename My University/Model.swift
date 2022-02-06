//
//  Model.swift
//  My University
//
//  Created by Yura Voevodin on 15.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

/// Classroom, Group, Teacher
protocol ModelProtocol {
    associatedtype CoreDataEntity: NSManagedObject
    
    var id: Int64 { get }
    var isFavorite: Bool { get }
    var name: String { get }
    var slug: String { get }
    var uuid: String? { get }
}

struct Model<Kind: ModelKind, Entity: CoreDataFetchProtocol & CoreDataEntityProtocol>: ModelProtocol {
    typealias CoreDataEntity = Entity
    
    var id: Int64
    var isFavorite: Bool
    var name: String
    var slug: String
    var uuid: String?
}

extension Model: EntityRepresentable {}

typealias Classroom = Model<ClassroomModel, ClassroomEntity>

typealias Group = Model<GroupModel, GroupEntity>

typealias Teacher = Model<TeacherModel, TeacherEntity>
