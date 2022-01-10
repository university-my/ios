//
//  NetworkError.swift
//  My University
//
//  Created by Yura Voevodin on 26.11.2021.
//  Copyright © 2021 Yura Voevodin. All rights reserved.
//

import Foundation

struct NetworkError: Error {
    
    let kind: ErrorKind
    
    enum ErrorKind {
        case dataNotFound
        case scheduleParsingError
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch kind {
        case .scheduleParsingError:
            return NSLocalizedString("We were unable to read the schedule from the university website", comment: "Error description")
        case .dataNotFound:
            return NSLocalizedString("Data not found", comment: "Error description")
        }
    }
}
