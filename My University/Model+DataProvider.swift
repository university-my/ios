//
//  Model+DataProvider.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

extension Model {
    
    class DataProvider {
        
        let networkClient: AsyncNetworkController
        
        internal init(networkClient: AsyncNetworkController = AsyncNetworkController()) {
            self.networkClient = networkClient
        }
        
        func load(universityURL: String) async throws -> [ModelCodingData] {
            let data = try await networkClient.fetch(universityURL: universityURL)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode([ModelCodingData].self, from: data)
            
            return decodedData
        }
        
        func records(modelID: Int64, universityURL: String, date: Date) async throws -> Record.RecordsList {
            let dateString = DateFormatter.short.string(from: date)
            let params = Record.RequestParameters(id: modelID, university: universityURL, date: dateString)
            let data = try await networkClient.fetchRecords(for: params)
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Record.RecordsList.self, from: data)
            
            return decodedData
        }
    }
}
