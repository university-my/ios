//
//  CoreDataEntityProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

protocol CoreDataEntityProtocol: NSManagedObject {
    
    // MARK: - Properties
    
    var id: Int64 { get set }
    var name: String? { get set }
    var isFavorite: Bool { get set }
    var slug: String? { get set }
    var uuid: UUID? { get set }
    var firstSymbol: String? { get set }
    var university: UniversityEntity? { get set }
    var records: NSSet? { get set }
    
    // MARK: - Methods
    
    func shareURL(for date: Date) -> URL?
}

extension CoreDataEntityProtocol {
    
    func pageParameters(with date: Date) -> WebsitePageParameters? {
        guard let slug = slug else {
            return nil
        }
        guard let universityURL = university?.url else {
            return nil
        }
        let dateString = DateFormatter.short.string(from: date)
        
        return WebsitePageParameters(slug: slug, university: universityURL, date: dateString)
    }
}
