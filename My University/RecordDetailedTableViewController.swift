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

class RecordDetailedTableViewController: GenericTableViewController {
    
    // MARK: - Types
    
    struct Section {
        let type: SectionType
        var rows: [RowType]
    }
    
    enum RowType {
        case pairName(name: String?, type: String?)
        case reason(reason: String)
        case auditorium(auditorium: AuditoriumEntity)
        case teacher(teacher: TeacherEntity)
        case group(group: GroupEntity)
    }
    
    enum SectionType {
        case pair
        case auditorium
        case teacher
        case groups
        
        var name: String {
            switch self {
            case .auditorium:
                return NSLocalizedString("AUDITORIUM", comment: "")
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
            updateWithPairDate()
            sections = generateSections()
        }
        
        showRateApp()
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
    
    // MARK: - Rate App
    
    // Check whether it is ready to show Rate alert
    private func shouldRatingApp(for date: Date?) -> Bool {
        guard let date = date else { return false }
        
        var dateComponent = DateComponents()
        dateComponent.day = 14
        
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)
        
        // Show only after passing two weeks since launching the app
        if futureDate != nil, futureDate! <= Date() {
            UserData.firstUsage = nil
            return true
        } else {
            return false
        }
    }
    
    private func showRateApp() {
        guard shouldRatingApp(for: UserData.firstUsage) else {
            return
        }
        guard let windowScene = UIApplication.shared.currentWindow?.windowScene else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
            SKStoreReviewController.requestReview(in: windowScene)
        })
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
        if let description = record.reason, description.isEmpty == false {
            pairSection.rows.append(.reason(reason: description))
        }
        sections.append(pairSection)
        
        // Auditorium
        if let auditorium = record.auditorium {
            let section = Section(type: .auditorium, rows: [.auditorium(auditorium: auditorium)])
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
        return sections.count
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
            
        case .auditorium(let auditorium):
            cell.textLabel?.text = auditorium.name
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
        return sections[section].type.name
    }
    
    // MARK: - Done
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
}
