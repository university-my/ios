//
//  ModelKind.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol ModelKind {
    
    static func allEntities(university: String) -> URL
    static func recordsEndpoint(params: Record.RequestParameters) -> URL
    
    static var cashFileName: String { get }
}

enum ModelKinds {
    
    enum ClassroomModel: ModelKind {
        
        static var cashFileName: String {
            "classrooms"
        }
        
        static func allEntities(university: String) -> URL {
            Auditorium.Endpoints.all(university: university).url
        }
        
        static func recordsEndpoint(params: Record.RequestParameters) -> URL {
            Auditorium.Endpoints.records(params: params).url
        }
    }
    
    enum GroupModel: ModelKind {
        
        static var cashFileName: String {
            "groups"
        }
        
        static func allEntities(university: String) -> URL {
            Group.Endpoints.all(university: university).url
        }
        
        static func recordsEndpoint(params: Record.RequestParameters) -> URL {
            Group.Endpoints.records(params: params).url
        }
    }
    
    enum TeacherModel: ModelKind {
        
        static var cashFileName: String {
            "teachers"
        }
        
        static func allEntities(university: String) -> URL {
            Teacher.Endpoints.all(university: university).url
        }
        
        static func recordsEndpoint(params: Record.RequestParameters) -> URL {
            Teacher.Endpoints.records(params: params).url
        }
    }
}
