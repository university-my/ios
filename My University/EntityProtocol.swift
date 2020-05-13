//
//  EntityProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 09.05.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

protocol EntityProtocol: NSManagedObject {
    var name: String? { get set }
    var favorite: Bool { get set }
    func shareURL(for date: Date) -> URL?
}
