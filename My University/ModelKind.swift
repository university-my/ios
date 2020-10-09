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
}

enum ModelKinds {
    
    enum ClassroomModel: ModelKind {
        
        static func allEntities(university: String) -> URL {
            Auditorium.Endpoints.all(university: university).url
        }
    }
    
    enum GroupModel: ModelKind {
        
        static func allEntities(university: String) -> URL {
            Group.Endpoints.all(university: university).url
        }
    }
    
    enum TeacherModel: ModelKind {
        
        static func allEntities(university: String) -> URL {
            Teacher.Endpoints.all(university: university).url
        }
    }
}
