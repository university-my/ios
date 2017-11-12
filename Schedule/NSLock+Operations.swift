//
//  NSLock+Operations.swift
//  Schedule
//
//  Created by Yura Voevodin on 11.11.17.
//  Copyright © 2017 Yura Voevodin. All rights reserved.
//

import Foundation

extension NSLock {
    
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
