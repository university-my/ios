//
//  ConfigTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

@testable import My_University
import XCTest

class ConfigTests: XCTestCase {
    
    func testMyUniversityURL() {
        XCTAssertEqual(URL.myUniversity.absoluteString, "http://localhost:3000")
    }

    func testMyUniversityAPIURL() {
        XCTAssertEqual(URL.myUniversityAPI.absoluteString, "http://localhost:3000/api/v1")
    }
    
    func testContactsURL() {
        XCTAssertEqual(URL.contacts.absoluteString, "http://localhost:3000/contacts")
    }
}
