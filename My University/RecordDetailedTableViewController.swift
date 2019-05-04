//
//  RecordDetailedTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 2/17/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class RecordDetailedTableViewController: GenericTableViewController {
    
    // MARK: - Types
    
    enum SectionType {
        case date(dateString: String)
        case pairName(name: String?, type: String?)
        case reason(reason: String)
        case auditorium(auditorium: AuditoriumEntity)
        case teacher(teacher: TeacherEntity)
        case groups(groups: NSSet)
        
        var name: String {
            switch self {
            case .auditorium:
                return NSLocalizedString("AUDITORIUM", comment: "")
            case .date(_):
                return NSLocalizedString("DATE", comment: "")
            case .groups(let groups):
                if groups.count > 1 {
                    return NSLocalizedString("GROUPS", comment: "")
                } else {
                    return NSLocalizedString("GROUP", comment: "")
                }
            case .pairName(_):
                return NSLocalizedString("NAME", comment: "")
            case .reason:
                return NSLocalizedString("DESCRIPTION", comment: "")
            case .teacher:
                return NSLocalizedString("TEACHER", comment: "")
            }
        }
    }
    
    // MARK: - Properties
    
    var recordID: Int64?
    private weak var record: RecordEntity?
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = recordID, let context = viewContext {
            record = RecordEntity.fetch(id: id, context: context)
        }
        
        title = nameAndTime()
        sections = generateSections()
    }
    
    /// Name and time
    private func nameAndTime() -> String? {
        guard let record = record else { return nil }
        var detail = ""
        if let pairName = record.pairName, let time = record.time {
            detail += pairName + " (\(time))"
        } else if let time = record.time {
            detail += "(\(time))"
        }
        return detail
    }
    
    // MARK: - Sections
    
    private var sections: [SectionType] = []
    
    private func generateSections() -> [SectionType] {
        guard let record = record else { return [] }
        var sections: [SectionType] = []
        
        // Name and type
        if (record.name != nil && record.name != "") || (record.type != nil && record.type != "") {
            sections.append(.pairName(name: record.name, type: record.type))
        }
        
        // Date
        if let date = record.date {
            let dateString = dateFormatter.string(from: date)
            sections.append(.date(dateString: dateString))
        }
        
        // Description
        if let description = record.reason, description.isEmpty == false {
            sections.append(.reason(reason: description))
        }
        
        // Auditorium
        if let auditorium = record.auditorium {
            sections.append(.auditorium(auditorium: auditorium))
        }
        
        // Teacher
        if let teacher = record.teacher {
            sections.append(.teacher(teacher: teacher))
        }
        
        // Groups
        if let groups = record.groups, groups.count != 0 {
            sections.append(.groups(groups: groups))
        }
        
        return sections
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        if case let SectionType.groups(groups) = section {
            return groups.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordDetailed", for: indexPath)
        cell.selectionStyle = .none
        
        let row = sections[indexPath.section]
        
        switch row {
            
        case .date(let dateString):
            // Date
            cell.textLabel?.text = dateString
            
            // Name and time
            cell.detailTextLabel?.text = nameAndTime()
            
        case .pairName(let name, let type):
            if let name = name, name.isEmpty == false {
                cell.textLabel?.text = name
                cell.detailTextLabel?.text = type
            } else if let type = type {
                cell.textLabel?.text = type
                cell.detailTextLabel?.text = nil
            }
            
        case .reason(let reason):
            cell.textLabel?.text = reason
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = nil
            
        case .auditorium(let auditorium):
            cell.textLabel?.text = auditorium.name
            cell.detailTextLabel?.text = nil
            
        case .teacher(let teacher):
            cell.textLabel?.text = teacher.name
            cell.detailTextLabel?.text = nil
            
        case .groups(let groups):
            let group = Array(groups)[indexPath.row] as? GroupEntity
            cell.textLabel?.text = group?.name
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
}
