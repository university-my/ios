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
    
    var sectionsTitles: [String] = []
    
    var barButtonItem = UIBarButtonItem()
    
    var sortBy: Filter {
        get {
            switch Filter.currentType {
            case 1:
                return .week
            case 2:
                return .month
            default:
                return .day
            }
        }
        set {
            Filter.currentType = newValue.rawValue
        }
    }
    
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
    
    // MARK: - Prepare Filters
    
    func configureFilterButton(state: Filter) {
        switch state {
        case .week, .month:
            barButtonItem.tintColor = UIColor.orange
            barButtonItem.image = UIImage(named: "AppliedFilters")
        default:
            barButtonItem.tintColor = UIColor.white
            barButtonItem.image = UIImage(named: "NoFilters")
        }
    }
    
    func setDataForFilters(period: Filter, entity: NSManagedObject) -> NSPredicate {
        var filterPredicate = NSPredicate()
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
        
        switch sortBy {
        case .week:
            if let startWeek = Date().startOfWeek, let endWeek = Date().endOfWeek {
                filterPredicate = NSPredicate(format: "\(preparePredicateForEntity) AND dateString >= %@ AND dateString <= %@", entity, startWeek as NSDate, endWeek as NSDate)
            }
            return filterPredicate
        case .month:
            dateFormatter.dateFormat = "YYYY-MM"
            let currentMonth = dateFormatter.string(from: Date())
            filterPredicate = NSPredicate(format: "\(preparePredicateForEntity) AND dateString CONTAINS %@", entity, currentMonth)
            return filterPredicate
        default:
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            filterPredicate = NSPredicate(format: "\(preparePredicateForEntity) AND dateString CONTAINS %@", entity, currentDate)
            return filterPredicate
        }
    }
    
    func showFilters(controller: UIViewController, entity: NSManagedObject, fetchedResultsController: NSFetchedResultsController<RecordEntity>?) {
        var filterPredicate = NSPredicate()
        let alert = UIAlertController(title: NSLocalizedString("Filter", comment: ""), message: NSLocalizedString("Show schedule for:", comment: ""), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Month", comment: ""), style: .default, handler: { (_) in
            self.sortBy = .month
            filterPredicate = self.setDataForFilters(period: self.sortBy, entity: entity)
            fetchedResultsController?.fetchRequest.predicate = filterPredicate
            self.configureFilterButton(state: self.sortBy)
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
            self.performFetch(fetchedResultsController: fetchedResultsController)
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Week", comment: ""), style: .default, handler: { (_) in
            self.sortBy = .week
filterPredicate = self.setDataForFilters(period: self.sortBy, entity: entity)
            fetchedResultsController?.fetchRequest.predicate = filterPredicate
            self.configureFilterButton(state: self.sortBy)
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
            self.performFetch(fetchedResultsController: fetchedResultsController)
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Day",comment: ""), style: .default, handler: { (_) in
            self.sortBy = .day
            filterPredicate = self.setDataForFilters(period: self.sortBy, entity: entity)
            fetchedResultsController?.fetchRequest.predicate = filterPredicate
            self.configureFilterButton(state: self.sortBy)
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error in the fetched results controller: \(error).")
            }
            self.performFetch(fetchedResultsController: fetchedResultsController)
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
        tableView.reloadData()
        controller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Fetch results from CoreData
    
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
