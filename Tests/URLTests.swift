//
//  URLTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

@testable import My_University
import XCTest

class URLTests: XCTestCase {
    
    private let university = "sumdu"
    private let localhost = MockHost.localhost
    
    func testMyUniversityURL() {
        XCTAssertEqual(URL.myUniversity.absoluteString, localhost.host)
        XCTAssertEqual(URL.myUniversityAPI.absoluteString, localhost.apiURL)
        XCTAssertEqual(URL.contacts.absoluteString, localhost.host + "/contacts")
    }
}
