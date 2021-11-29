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
        
        let decoder = JSONDecoder()
        let client = NetworkClient<Record.RecordsList>()
        client.load(Record.Endpoints.testRecords.url, decoder: decoder) { (result) in
            switch result {
                
            case .failure(let error):
                XCTFail("\(error)")
                
            case .success(let list):
                if !list.records.isEmpty {
                    expectations.fulfill()
                }
            }
        }
        
        wait(for: [expectations], timeout: 2)
    }
    
    /// Send request to the test API endpoint ant try to serialise response
    func testRecordsParsingError() {
        let expectations = expectation(description: "Error")
        
        let decoder = JSONDecoder()
        
        
        let task = URLSession.shared.dataTask(with: Record.Endpoints.testRecordsParsingError.url) { data, response, error in
            
            guard let data = data else {
                return
            }
            
            do {
                let status = try decoder.decode(NetworkStatus.CodingData.self, from: data)
                
                if status.code == NetworkStatus.Code.scheduleParsingError {
                    expectations.fulfill()
                }
            } catch {
                XCTFail("\(error)")
            }
        }
        task.resume()
        
        wait(for: [expectations], timeout: 2)
    }
    
    /// Send request to the test API endpoint using `NetworkClient` and try to serialise response
    func testScheduleParsingNetworkError() {
        let expectations = expectation(description: "Error")
        
        let decoder = JSONDecoder()
        let client = NetworkClient<Record.RecordsList>()
        client.load(Record.Endpoints.testRecordsParsingError.url, decoder: decoder) { (result) in
            switch result {
                
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    if networkError.kind == .scheduleParsingError {
                        expectations.fulfill()
                    }
                }
                
            case .success(_):
                break
            }
        }
        
        wait(for: [expectations], timeout: 2)
    }
    
    /// Send request to the test API endpoint using `NetworkClient` and Publisher, try to serialise response
    func testScheduleParsingNetworkErrorWithPublisher() {
        let expectations = expectation(description: "Error")
        
        let decoder = JSONDecoder()
        let client = NetworkClient<Record.RecordsList>()
        client.load(Record.Endpoints.testRecordsParsingError.url, decoder: decoder) { (result) in
            switch result {
                
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    if networkError.kind == .scheduleParsingError {
                        expectations.fulfill()
                    }
                }
                
            case .success(_):
                break
            }
        }
        
        wait(for: [expectations], timeout: 2)
    }
}
