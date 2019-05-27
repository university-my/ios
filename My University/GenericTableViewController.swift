//
//  GenericTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/19/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit
import CoreData

class GenericTableViewController: UITableViewController {

    // MARK: - Properties
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        return dateFormatter
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .cellSelectionColor
        cell.selectedBackgroundView = bgColorView
    }
    
    // MARK: - Notification
    
    var notificationLabel = UILabel(frame: CGRect.zero)
    
    func configureNotificationLabel() {
        notificationLabel.sizeToFit()
        notificationLabel.backgroundColor = .clear
        notificationLabel.textAlignment = .center
        notificationLabel.textColor = .lightGray
        notificationLabel.adjustsFontSizeToFitWidth = true
        notificationLabel.minimumScaleFactor = 0.5
    }
    
    func showNotification(text: String?) {
        notificationLabel.text = text
        notificationLabel.sizeToFit()
    }
    
    func hideNotification() {
        notificationLabel.text = nil
    }

    // MARK: - Period button

    var barButtonItem = UIBarButtonItem()

    func configurePeriodButton() {
        barButtonItem.title = currentPeriod.title
    }

    // MARK: - Period

    var currentPeriod: Period {
        get {
            return Period.current
        }
        set {
            Period.current = newValue
        }
    }
    
    func predicate(for period: Period, entity: NSManagedObject) -> NSPredicate {
        var predicate = NSPredicate()
        let dateFormatter = DateFormatter()
        var preparePredicateForEntity = String()
        
        switch entity {
        case is AuditoriumEntity:
            preparePredicateForEntity = "auditorium == %@"
        case is GroupEntity:
            preparePredicateForEntity = "ANY groups == %@"
        case is TeacherEntity:
            preparePredicateForEntity = "teacher == %@"
        default:
            preparePredicateForEntity = ""
        }

        switch currentPeriod {
        case .today:
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            predicate = NSPredicate(format: "\(preparePredicateForEntity) AND dateString CONTAINS %@", entity, currentDate)
            return predicate

        case .week:
            let startDate = Date()
            let endDate = startDate.plusSevenDays()
            predicate = NSPredicate(format: "\(preparePredicateForEntity) AND dateString >= %@ AND dateString <= %@", entity, startDate as NSDate, endDate as NSDate)
            return predicate
        }
    }
    
    func fetchDataForPeriod(entity: NSManagedObject, fetchedResultsController: NSFetchedResultsController<RecordEntity>?) {

        switch currentPeriod {
        case .today:
            currentPeriod = .week
        case .week:
            currentPeriod = .today
        }

        configurePeriodButton()
        fetchedResultsController?.fetchRequest.predicate = predicate(for: currentPeriod, entity: entity)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
        performFetch(fetchedResultsController: fetchedResultsController)
        tableView.reloadData()
    }
    
    // MARK: - Favorites
    
    func setupFavoriteButton(_ button: UIBarButtonItem, favorite: Bool) {
        button.image = UIImage(named: "Favorite")
        if favorite {
            button.tintColor = UIColor.orange
        } else {
            button.tintColor = UIColor.white
        }
    }
    
    func markAsFavorite(for entity: NSManagedObject, mark: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let persistentContainer = appDelegate?.persistentContainer else { return }
        
        let taskContext = persistentContainer.viewContext
        
        switch entity {
        case is AuditoriumEntity:
            let auditorium = entity as? AuditoriumEntity
            guard let auditoriumID = auditorium?.id else { return }
            
            let auditoriumEntity = AuditoriumEntity.fetch(id: auditoriumID, context: taskContext)
            
            do {
                auditoriumEntity?.setValue(mark, forKey: "favorite")
                try taskContext.save()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
        case is GroupEntity:
            let group = entity as? GroupEntity
            guard let groupID = group?.id else { return }
            
            let groupEntity = GroupEntity.fetch(id: groupID, context: taskContext)
            
            do {
                groupEntity?.setValue(mark, forKey: "favorite")
                try taskContext.save()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
        case is TeacherEntity:
            let teacher = entity as? TeacherEntity
            guard let teacherID = teacher?.id else { return }
            
            let teacherEntity = TeacherEntity.fetchTeacher(id: teacherID, context: taskContext)
            
            do {
                teacherEntity?.setValue(mark, forKey: "favorite")
                try taskContext.save()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
        default:
            print ("there are no entities!")
        }
    }
    
    // MARK: - Fetch results from CoreData

    var sectionsTitles: [String] = []
    
    func performFetch(fetchedResultsController: NSFetchedResultsController<RecordEntity>?) {
        do {
            try fetchedResultsController?.performFetch()
            
            // Generate title for sections
            if let controller = fetchedResultsController, let sections = controller.sections {
                var newSectionsTitles: [String] = []
                for section in sections {
                    if let firstObjectInSection = section.objects?.first as? RecordEntity {
                        if let date = firstObjectInSection.date {
                            let dateString = dateFormatter.string(from: date)
                            newSectionsTitles.append(dateString)
                        }
                    }
                }
                sectionsTitles = newSectionsTitles
            }
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}
