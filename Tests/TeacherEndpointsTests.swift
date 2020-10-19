//
//  TeacherEndpointsTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

@testable import My_University
import XCTest

class TeacherEndpointsTests: XCTestCase {
    
    private let localhost = MockHost.localhost
    private let university = "sumdu"
    private let date = "2020-10-10"
    
    func testTeacherWebsitePageURL() {
        let slug = "in-81"

        let endpoint = Teacher.Endpoints.websitePage(
            from: WebsitePageParameters(
                slug: slug,
                university: university,
                date: date
            )
        )
        XCTAssertEqual(
            endpoint.url.absoluteString,
            localhost.host + "/universities/\(university)/teachers/\(slug)?pair_date=\(date)"
        )
    }
    
    func testTeacherURLs() {
        XCTAssertEqual(
            Teacher.Endpoints.all(university: university).url.absoluteString,
            localhost.apiURL + "/universities/\(university)/teachers"
        )
        
        // Records
        let id: Int64 = 1
        XCTAssertEqual(
            Teacher.Endpoints.records(params:
                                        Record.RequestParameters(
                                            id: id,
                                            university: university,
                                            date: date
                                        )
            ).url.absoluteString,
            localhost.apiURL + "/universities/\(university)/teachers/\(id)/records?pair_date=\(date)"
        )
    }
}
