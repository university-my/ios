//
//  UniversitiesListDataProvider.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

struct UniversitiesListDataProvider {
    
    let networkClient: UniversitiesListNetworkClient
    
    internal init(networkClient: UniversitiesListNetworkClient) {
        self.networkClient = networkClient
    }
    
    func load() async throws -> [University.CodingData] {
        let data = try await networkClient.fetchUniversities()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decodedData = try decoder.decode([University.CodingData].self, from: data)
        
        return decodedData
    }
}
