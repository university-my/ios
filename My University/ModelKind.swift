//
//  ModelKind.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation
import CoreData

protocol ModelKind {
    
    // MARK: API
    
    static var cashFileName: String { get }
    
    /// For remote server API
    static var entityPath: String { get }
    
    static func allEntities(university: String) -> URL
    static func recordsEndpoint(params: Record.RequestParameters) -> URL
    
    // MARK: Core Data
    
    static func fetchRequestPredicate(for entity: CoreDataFetchable & CoreDataEntityProtocol) -> NSPredicate
}

enum ModelKinds {
    
    enum ClassroomModel: ModelKind {
        
        static var entityPath: String {
            "auditoriums"
        }
        
        static var cashFileName: String {
            "classrooms"
        }
        
        static func allEntities(university: String) -> URL {
            Classroom.Endpoints.all(university: university).url
        }
        
        static func recordsEndpoint(params: Record.RequestParameters) -> URL {
            Classroom.Endpoints.records(params: params).url
        }
        
        static func fetchRequestPredicate(for entity: CoreDataEntityProtocol & CoreDataFetchable) -> NSPredicate {
            NSPredicate(format: "classroom == %@", entity)
        }
    }
    
    enum GroupModel: ModelKind {
        
        static var entityPath: String {
            "groups"
        }
        
        static var cashFileName: String {
            "groups"
        }
        
        static func allEntities(university: String) -> URL {
            Group.Endpoints.all(university: university).url
        }
        
        static func recordsEndpoint(params: Record.RequestParameters) -> URL {
            Group.Endpoints.records(params: params).url
        }
        
        static func fetchRequestPredicate(for entity: CoreDataEntityProtocol & CoreDataFetchable) -> NSPredicate {
            NSPredicate(format: "ANY groups == %@", entity)
        }
    }
    
    enum TeacherModel: ModelKind {
        
        static var entityPath: String {
            "teachers"
        }
        
        static var cashFileName: String {
            "teachers"
        }
        
        static func allEntities(university: String) -> URL {
            Teacher.Endpoints.all(university: university).url
        }
        
        static func recordsEndpoint(params: Record.RequestParameters) -> URL {
            Teacher.Endpoints.records(params: params).url
        }
        
        static func fetchRequestPredicate(for entity: CoreDataEntityProtocol & CoreDataFetchable) -> NSPredicate {
            NSPredicate(format: "teacher == %@", entity)
        }
    }
}
