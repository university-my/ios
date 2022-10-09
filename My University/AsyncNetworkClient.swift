//
//  AsyncNetworkClient.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

protocol AsyncNetworkClient {}

extension AsyncNetworkClient {
    
    func loadData(from url: URL) async throws -> Data {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        
        if let appVersion = Bundle.main.shortVersion {
            request.addValue("My University \(appVersion)", forHTTPHeaderField: "User-Agent")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
            
        case 404:
            throw URLError(.badServerResponse)
            
        case 500:
            // Check parsing error
            let error = decodeNetworkStatus(from: data)
            throw error
            
        default:
            break
        }
        
        return data
    }
}

private extension AsyncNetworkClient {
    
    func decodeNetworkStatus(from data: Data) -> Error {
        let decoder = JSONDecoder()
        
        guard let status = try? decoder.decode(NetworkStatus.CodingData.self, from: data) else {
            return URLError(.badServerResponse)
        }
        
        switch status.code {
        case .scheduleParsingError:
            return NetworkError.scheduleParsingError
        }
    }
}
