//
//  RecordStruct.swift
//  Schedule
//
//  Created by Yura Voevodin on 23.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

struct Record {
  
  // MARK: - Properties
  
  let id: Int64
  let time: String
  let dateString: String
  let date: Date?
  let type: String?
  let name: String?
  let pairName: String
  let reason: String?
  let auditorium: Auditorium?
  let groups: [Group]
  let teacher: Teacher?
  
  // MARK: - Initialization
  
  init?(_ json: [String: Any], dateFormatter: ISO8601DateFormatter) {
    guard let id = json["id"] as? Int64 else {
      return nil
    }
    guard let time = json["time"] as? String else {
      return nil
    }
    guard let dateString = json["start_date"] as? String else {
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
    var groups: [Group] = []
    if let groupsObject = json["groups"] as? [Any] {
      for item in groupsObject {
        if let groupObject = item as? [String: Any] {
          if let group = Group(groupObject) {
            groups.append(group)
          }
        }
      }
    }
    self.groups = groups
    
    // Teacher
    if let teacherObject = json["teacher"] as? [String: Any] {
      self.teacher = Teacher(teacherObject)
    } else {
      self.teacher = nil
    }
    
    // Date
    self.date = dateFormatter.date(from: dateString)
  }
}
