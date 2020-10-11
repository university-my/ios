//
//  EntityProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

protocol EntityProtocol: NSManagedObject {
    
    // MARK: - Properties
    
    var name: String? { get set }
    var favorite: Bool { get set }
    var slug: String? { get set }
    var university: UniversityEntity? { get set }
    
    // MARK: - Methods
    
    func shareURL(for date: Date) -> URL?
}

extension EntityProtocol {
    
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
