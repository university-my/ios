//
//  UniversityDataSource.swift
//  My University
//
//  Created by Yura Voevodin on 4/15/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class UniversitiesDataSource: NSObject {

    // MARK: - NSManagedObjectContext

    private lazy var persistentContainer: NSPersistentContainer? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer
    }()

    private lazy var viewContext: NSManagedObjectContext? = {
        return persistentContainer?.viewContext
    }()

    // MARK: - NSFetchedResultsController

    lazy var fetchedResultsController: NSFetchedResultsController<UniversityEntity>? = {
        let request: NSFetchRequest<UniversityEntity> = UniversityEntity.fetchRequest()

        let name = NSSortDescriptor(key: #keyPath(UniversityEntity.shortName), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))

        request.sortDescriptors = [name]
        request.fetchBatchSize = 20

        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()

    func fetchUniversities() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }
    }

    // MARK: - Import Universities

    private var universitiesImportManager: University.Import?

    func importUniversities(_ completion: @escaping ((_ error: Error?) -> ())) {
        // Do nothing without CoreData.
        guard let persistentContainer = persistentContainer else { return }

        universitiesImportManager = University.Import(persistentContainer: persistentContainer)
        DispatchQueue.global().async { [weak self] in

            self?.universitiesImportManager?.importUniversities({ (error) in

                DispatchQueue.main.async {
                    completion(error)
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource

extension UniversitiesDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[safe: section]
        return section?.numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "universityCell", for: indexPath)

        // Configure cell
        if let university = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = university.shortName
            cell.detailTextLabel?.text = university.fullName
        }

        return cell
    }
}
