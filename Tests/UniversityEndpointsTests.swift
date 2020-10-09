//
//  UniversityEndpointsTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

@testable import My_University
import XCTest

class UniversityEndpointsTests: XCTestCase {
    
    private let localhost = MockHost.localhost

    func testAllUniversitiesEndpoint() {
        XCTAssertEqual(
            University.Endpoints.allUniversities.url.absoluteString,
            localhost.apiURL + "/universities"
        )
    }
}
