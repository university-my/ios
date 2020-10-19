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
    
    func testUniversitiesLoading() {
        let expectations = expectation(description: "Universities")
        
        let client = NetworkClient<[University.CodingData]>()
        client.load(url: University.Endpoints.allUniversities.url) { (result) in
            switch result {
            
            case .failure(let error):
                XCTFail("\(error)")
                
            case .success(let data):
                if !data.isEmpty {
                    expectations.fulfill()
                }
            }
        }
        
        wait(for: [expectations], timeout: 5)
    }
}
