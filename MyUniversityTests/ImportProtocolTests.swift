//
//  MyUniversityTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 30.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

@testable import My_University
import XCTest

class ImportProtocolTests: XCTestCase {
    
    struct TestStruct: ImportProtocol {
        
    }

    func testNeedToUpdate() {
        // Current day
        let notNeedToUpdate = TestStruct.needToUpdate(from: Date())
        XCTAssert(notNeedToUpdate == false)
        
        // Next day
        let calendar = Calendar.current
        if let nextDate = calendar.date(byAdding: .day, value: 1, to: Date()) {
            let needToUpdate = TestStruct.needToUpdate(from: nextDate)
            XCTAssert(needToUpdate)
        }
    }
}
