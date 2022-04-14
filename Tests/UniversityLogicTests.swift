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
    
    override func setUpWithError() throws {
        let logic = UniversityViewController.UniversityLogicController()
        
        // Reset old value
        logic.resetLatestVersionForNewFeatures()
    }

    override func tearDownWithError() throws {
        // This method is called after the invocation of each test method in the class.
        let logic = UniversityViewController.UniversityLogicController()
        
        // Reset again
        logic.resetLatestVersionForNewFeatures()
    }

    func testWhatsNewFeature() {
        let logic = UniversityViewController.UniversityLogicController()
        
        // Should be `true` for new app version
        XCTAssertFalse(logic.needToPresentWhatsNew())
        
        logic.updateLastVersionForNewFeatures()
        XCTAssertFalse(logic.needToPresentWhatsNew())
    }
    
    func testWhatsNewFeatureWithSpecifiedVersion() {
        let logic = UniversityViewController.UniversityLogicController()
        
        // Should fails when app version is changed
        XCTAssertTrue(logic.needToPresentWhatsNew(for: "1.7.5"))
        XCTAssertFalse(logic.needToPresentWhatsNew(for: "1.7.6"))
        XCTAssertFalse(logic.needToPresentWhatsNew(for: "1.7.7"))
    }
}
