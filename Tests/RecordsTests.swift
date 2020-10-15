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
        
        let client = Record.NetworkClient<ModelKinds.ClassroomModel>()
        client.loadTestRecords { (result) in
            switch result {
            
            case .failure(let error):
                XCTFail("Import fail: \(error)")
                
            case .success(let list):
                if !list.records.isEmpty {
                    expectations.fulfill()
                }
            }
        }

        wait(for: [expectations], timeout: 5)
    }
    
    func testRecordsLoadingWithPublisher() {
        let expectations = expectation(description: "Records")
        
        let client = Record.NetworkClient<ModelKinds.ClassroomModel>()
        let params = Record.RequestParameters(id: 1, university: "sumdu", date: "2020-10-10")
        
        client.loadRecords(params) { (result) in
            expectations.fulfill()
        }
        
        wait(for: [expectations], timeout: 5)
    }
}
