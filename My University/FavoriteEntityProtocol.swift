//
//  FavoriteEntityProtocol.swift
//  My University
//
//  Created by Yura Voevodin on 27.04.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import CoreData

protocol FavoriteEntityProtocol: NSManagedObject {
    
    var favorite: Bool { get set }
}

extension FavoriteEntityProtocol {
    
    func toggleFavorite() {
        favorite.toggle()
    }
}
