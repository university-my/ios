//
//  RecordDetailedTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 2/17/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit
import StoreKit

protocol RecordDetailedTableViewControllerDelegate: AnyObject {
    func didDismissDetails(in viewController: RecordDetailedTableViewController)
}

class RecordDetailedTableViewController: UITableViewController {
    
    // MARK: - Types
    
    struct Section {
        let type: SectionType
        var rows: [RowType]
    }
    
    enum RowType {
        case pairName(name: String?, type: String?)
        case reason(reason: String)
        case classroom(classroom: ClassroomEntity)
        case teacher(teacher: TeacherEntity)
        case group(group: GroupEntity)
    }
    
    enum SectionType {
        case pair
        case classroom
        case teacher
        case groups
        
        var name: String {
            switch self {
            case .classroom:
                return NSLocalizedString("CLASSROOM", comment: "")
            case .groups:
                return NSLocalizedString("GROUPS", comment: "")
            case .pair:
                return NSLocalizedString("PAIR", comment: "")
            case .teacher:
                return NSLocalizedString("TEACHER", comment: "")
            }
        }
    }
    
    // MARK: - Properties
    
    var classroomID: Int64?
    var groupID: Int64?
    var teacherID: Int64?
    
    var recordID: Int64?
    private weak var record: RecordEntity?
    
    weak var delegate: RecordDetailedTableViewControllerDelegate?
    
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
        guard let id = recordID, let context = viewContext else {
            preconditionFailure()
        }
        record = RecordEntity.fetch(id: id, context: context)
        title = nameAndTime()
        updateWithPairDate()
        sections = generateSections()
        
        // For the Review Request
        // If the count has not yet been stored, this will return 0
        var count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.recordDetailsOpenedCountKey)
        count += 1
        UserDefaults.standard.set(count, forKey: UserDefaultsKeys.recordDetailsOpenedCountKey)
    }
    
    // MARK: - Date
    
    @IBOutlet weak var dateLabel: UILabel!
    
    /// Date in table header
    private func updateWithPairDate() {
        if let date = record?.date {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
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
    
    private var sections: [Section] = []
    
    private func generateSections() -> [Section] {
        guard let record = record else { return [] }
        
        var sections: [Section] = []
        
        // Pair
        var pairSection = Section(type: .pair, rows: [])
        
        // Name and type
        if let name = record.name, name.isEmpty == false {
            pairSection.rows.append(.pairName(name: record.name, type: record.type))
            
        } else if let type = record.type, type.isEmpty == false {
            pairSection.rows.append(.pairName(name: record.name, type: record.type))
        }
        
        // Description
        if let description = Record.Formatter.reason(from: record.asStruct()), description.isEmpty == false {
            pairSection.rows.append(.reason(reason: description))
        }
        sections.append(pairSection)
        
        // Classroom
        if let classroom = record.classroom {
            let section = Section(type: .classroom, rows: [.classroom(classroom: classroom)])
            sections.append(section)
        }
        
        // Teacher
        if let teacher = record.teacher {
            let section = Section(type: .teacher, rows: [.teacher(teacher: teacher)])
            sections.append(section)
        }
        
        // Groups
        if let groups = record.groups, groups.count != 0 {
            var groupsRows: [RowType] = []
            groups.forEach { (group) in
                if let group = group as? GroupEntity {
                    groupsRows.append(.group(group: group))
                }
            }
            let groupsSection = Section(type: .groups, rows: groupsRows)
            sections.append(groupsSection)
        }
        
        return sections
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = sections[section]
        return currentSection.rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordDetailed", for: indexPath)
        cell.selectionStyle = .none
        
        let row = sections[indexPath.section].rows[indexPath.row]
        
        switch row {
            
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
            
        case .classroom(let classroom):
            cell.textLabel?.text = classroom.name
            cell.detailTextLabel?.text = nil
            
        case .teacher(let teacher):
            cell.textLabel?.text = teacher.name
            cell.detailTextLabel?.text = nil
            
        case .group(let group):
            cell.textLabel?.text = group.name
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].type.name
    }
    
    // MARK: - Done
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didDismissDetails(in: self)
        }
    }
}
