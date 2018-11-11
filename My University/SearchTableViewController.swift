//
//  SearchTableViewController.swift
//  My University
//
//  Created by Yura Voevodin on 11/11/18.
//  Copyright © 2018 Yura Voevodin. All rights reserved.
//

import CoreData
import UIKit

class SearchTableViewController: UITableViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Auditoriums
        loadAuditoriums()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - NSManagedObjectContext
    
    private lazy var viewContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }()
    
    // MARK: - Auditoriums
    
    private func loadAuditoriums()  {
        fetchAuditoriums()
        let auditoriums = auditoriumsResultsController?.fetchedObjects ?? []
        if auditoriums.isEmpty {
            importAuditoriums()
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: Import Auditoriums
    
    private var auditoriumsImportManager: Auditorium.ImportManager?
    
    /// Import Auditoriums from backend
    private func importAuditoriums() {
        // Do nothing without CoreData.
        guard let context = viewContext else { return }
        
        auditoriumsImportManager = Auditorium.ImportManager(context: context)
        DispatchQueue.global().async {
            self.auditoriumsImportManager?.importAuditoriums({ (error) in
                
                if let error = error {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            })
        }
    }
    
    // MARK: Fetch Auditoriums
    
    private lazy var auditoriumsResultsController: NSFetchedResultsController<AuditoriumEntity>? = {
        let request: NSFetchRequest<AuditoriumEntity> = AuditoriumEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        ]
        request.fetchBatchSize = 20
        
        if let context = viewContext {
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            return controller
        } else {
            return nil
        }
    }()
    
    private func fetchAuditoriums() {
        do {
            auditoriumsResultsController?.delegate = self
            try auditoriumsResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SearchTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        print(controller)
    }
}
