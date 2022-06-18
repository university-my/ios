//
//  UniversitiesListNetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

struct UniversitiesListNetworkClient: AsyncNetworkClient {
    
    func fetchUniversities() async throws -> Data {
        let url = University.Endpoints.allUniversities.url
        let data = try await loadData(from: url)
        return data
    }
}
