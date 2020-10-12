//
//  RecordsTests.swift
//  MyUniversityTests
//
//  Created by Yura Voevodin on 19.02.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import XCTest
@testable import My_University

class RecordsTests: XCTestCase {

    func testRecordsLoading() {
        let expectations = expectation(description: "Records")

        Record.NetworkClient<ModelKinds.ClassroomModel>.loadTestRecords { (records) in
            if !records.isEmpty {
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 5)
    }
}
