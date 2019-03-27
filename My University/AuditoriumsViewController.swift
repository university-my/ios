//
//  AuditoriumsViewController.swift
//  My University
//
//  Created by Yura Voevodin on 3/27/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class AuditoriumsViewController: GenericTableDelegateViewController {
    
    // MARK: - Properties
    
    private lazy var auditoriumDataSource: AuditoriumDataSource = {
        return AuditoriumDataSource()
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        // Large titles (works only when enabled from code).
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Loading...
        loadAuditoriums()
    }
    
    // MARK: - Auditoriums
    
    private func loadAuditoriums()  {
        tableView.dataSource = auditoriumDataSource
        auditoriumDataSource.fetchAuditoriums()
        
        let auditoriums = auditoriumDataSource.fetchedResultsController?.fetchedObjects ?? []
        
        if auditoriums.isEmpty {
            
            tableView.isHidden = true
            activityIndicator.startAnimating()
            
            auditoriumDataSource.importAuditoriums { (error) in
                
                if let error = error {
                    let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.auditoriumDataSource.fetchAuditoriums()
                self.tableView.reloadData()
            }
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
