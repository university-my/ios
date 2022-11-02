//
//  Model+AsyncNetworkController.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

extension Model {
    
    class AsyncNetworkController: AsyncNetworkClient {
        
        func fetch(universityURL: String) async throws -> Data {
            let url = Kind.allEntities(university: universityURL)
            
            let data = try await loadData(from: url)
            return data
        }
        
        func fetchRecords(for parameters: Record.RequestParameters) async throws -> Data {
            let url = Kind.recordsEndpoint(params: parameters)
            let data = try await loadData(from: url)
            return data
        }
    }
}
