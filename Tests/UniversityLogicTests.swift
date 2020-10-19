//
//  UniversityLogicTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 30.09.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import XCTest
@testable import My_University

class UniversityLogicTests: XCTestCase {

    func testWhatsNewFeature() {
        let logic = UniversityViewController.UniversityLogicController()
        
        // Reset old value
        logic.resetLastVersionForNewFeatures()
        
        XCTAssert(logic.needToPresentWhatsNew())
        
        logic.updateLastVersionForNewFeatures()
        XCTAssertFalse(logic.needToPresentWhatsNew())
        
        // Reset again
        logic.resetLastVersionForNewFeatures()
    }
}
