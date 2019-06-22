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
    
    var auditoriumID: Int64?
    var groupID: Int64?
    var teacherID: Int64?
    
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
        
        setup()
    }
    
    func setup() {
        if let id = recordID, let context = viewContext {
            record = RecordEntity.fetch(id: id, context: context)
            title = nameAndTime()
            sections = generateSections()
        }
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
        if let name = record.name, name.isEmpty == false {
            sections.append(.pairName(name: record.name, type: record.type))
            
        } else if let type = record.type, type.isEmpty == false {
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
            cell.accessoryType = .none
            // Date
            cell.textLabel?.text = dateString
            
            // Name and time
            cell.detailTextLabel?.text = nameAndTime()
            
        case .pairName(let name, let type):
            cell.accessoryType = .none
            if let name = name, name.isEmpty == false {
                cell.textLabel?.text = name
                cell.detailTextLabel?.text = type
            } else if let type = type {
                cell.textLabel?.text = type
                cell.detailTextLabel?.text = nil
            }
            
        case .reason(let reason):
            cell.accessoryType = .none
            cell.textLabel?.text = reason
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = nil
            
        case .auditorium(let auditorium):
            if let id = auditoriumID, id == auditorium.id {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
            cell.textLabel?.text = auditorium.name
            cell.detailTextLabel?.text = nil
            
        case .teacher(let teacher):
            if let id = teacherID, id == teacher.id {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
            cell.textLabel?.text = teacher.name
            cell.detailTextLabel?.text = nil
            
        case .groups(let groups):
            let group = Array(groups)[indexPath.row] as? GroupEntity
            cell.textLabel?.text = group?.name
            cell.detailTextLabel?.text = nil
            if group?.id == groupID {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        
        switch section {
        case .teacher(let teacher):
            if teacherID != teacher.id {
                performSegue(withIdentifier: "showTeacher", sender: nil)
            }
            
        case .groups(let groups):
            let group = Array(groups)[indexPath.row] as? GroupEntity
            if group?.id != groupID {
                performSegue(withIdentifier: "showGroup", sender: nil)
            }
            
        case .auditorium(let auditorium):
            if auditoriumID != auditorium.id {
                performSegue(withIdentifier: "showAuditorium", sender: nil)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showTeacher":
            if let detailTableViewController = segue.destination as? TeacherTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let section = sections[indexPath.section]
                    if case SectionType.teacher(let teacher) = section {
                        detailTableViewController.teacherID = teacher.id
                    }
                }
            }
            
        case "showGroup":
            if let detailTableViewController = segue.destination as? GroupTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let section = sections[indexPath.section]
                    if case SectionType.groups(let groups) = section {
                        if let group = Array(groups)[indexPath.row] as? GroupEntity {
                            detailTableViewController.groupID = group.id
                        }
                    }
                }
            }
            
        case "showAuditorium":
            if let detailTableViewController = segue.destination as? AuditoriumTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let section = sections[indexPath.section]
                    if case SectionType.auditorium(let auditorium) = section {
                        detailTableViewController.auditoriumID = auditorium.id
                    }
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - UIStateRestoring

extension RecordDetailedTableViewController {

  override func encodeRestorableState(with coder: NSCoder) {
    if let id = recordID {
      coder.encode(id, forKey: "recordID")
    }
    super.encodeRestorableState(with: coder)
  }

  override func decodeRestorableState(with coder: NSCoder) {
    recordID = coder.decodeInt64(forKey: "recordID")
  }
    
    override func applicationFinishedRestoringState() {
        setup()
    }
}
