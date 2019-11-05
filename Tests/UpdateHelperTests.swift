//
//  UpdateHelperTests.swift
//  Tests
//
//  Created by Yura Voevodin on 30.10.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

@testable import My_University
import XCTest

class UpdateHelperTests: XCTestCase {

    func testNeedToUpdate() {
        // Current day
        let notNeedToUpdate = UpdateHelper.needToUpdate(from: Date())
        XCTAssert(notNeedToUpdate == false)
        
        // Next day
        let calendar = Calendar.current
        if let nextDate = calendar.date(byAdding: .day, value: 3, to: Date()) {
            let needToUpdate = UpdateHelper.needToUpdate(from: nextDate)
            XCTAssert(needToUpdate)
        }
        
        // 1970
        let date = Date(timeIntervalSince1970: 1)
        let needToUpdate = UpdateHelper.needToUpdate(from: date)
        XCTAssert(needToUpdate)
    }
}
