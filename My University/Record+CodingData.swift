//
//  Record+CodingData.swift
//  My University
//
//  Created by Yura Voevodin on 27.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

extension Record {
    
    struct CodingData {
        // TODO: Use `Codable`
        
        // MARK: - Properties
        
        let id: Int64
        let time: String
        let dateString: String
        let date: Date?
        
        /// Type of the pair (lecture or practical work)
        let type: String?
        
        /// Name of the pair (discipline)
        let name: String?
        let pairName: String
        
        /// Description or comment
        let reason: String?
        let auditorium: Auditorium?
        let groups: [Group.CodingData]
        let teacher: Teacher.CodingData?
        
        // MARK: - Initialization
        
        init?(_ json: [String: Any], dateFormatter: ISO8601DateFormatter) {
            guard let id = json["id"] as? Int64 else {
                return nil
            }
            guard let time = json["time"] as? String else {
                return nil
            }
            guard let dateString = json["pair_start_date"] as? String else {
                return nil
            }
            let type = json["kind"] as? String
            let name = json["name"] as? String
            
            guard let pairName = json["pair_name"] as? String else {
                return nil
            }
            let reason = json["reason"] as? String
            
            self.id = id
            self.time = time
            self.dateString = dateString
            self.type = type
            self.name = name
            self.pairName = pairName
            self.reason = reason
            
            // Auditorium
            if let auditoriumObject = json["auditorium"] as? [String: Any] {
                self.auditorium = Auditorium(auditoriumObject)
            } else {
                self.auditorium = nil
            }
            
            // Groups
            var groups: [Group.CodingData] = []
            if let groupsObject = json["groups"] as? [Any] {
                for item in groupsObject {
                    if let groupObject = item as? [String: Any] {
                        if let group = Group.CodingData(groupObject) {
                            groups.append(group)
                        }
                    }
                }
            }
            self.groups = groups
            
            // Teacher
            if let teacherObject = json["teacher"] as? [String: Any] {
                self.teacher = Teacher.CodingData(teacherObject)
            } else {
                self.teacher = nil
            }
            
            // Date
            self.date = dateFormatter.date(from: dateString)
        }
    }
}
