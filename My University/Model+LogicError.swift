//
//  Model+LogicError.swift
//  My University
//
//  Created by Yura Voevodin on 17.12.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

enum LogicError: Error {
    case UUIDNotEqual
    case UUIDNotFound
}

extension LogicError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .UUIDNotEqual, .UUIDNotFound:
            return NSLocalizedString("University data needs to be updated. You will return to the main screen of the university", comment: "Error description")
        }
    }
}
