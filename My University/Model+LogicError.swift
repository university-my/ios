//
//  Model+LogicError.swift
//  My University
//
//  Created by Yura Voevodin on 17.12.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

struct LogicError: Error {
    
    let kind: ErrorKind
    
    enum ErrorKind {
        case UUIDNotFound
    }
}

extension LogicError: LocalizedError {
    var errorDescription: String? {
        switch kind {
        case .UUIDNotFound:
            return NSLocalizedString("You need to update the university data, you will return to the main screen of the university", comment: "Error description")
        }
    }
}
