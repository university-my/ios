//
//  ModelData.swift
//  My University
//
//  Created by Yura Voevodin on 01.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import Foundation

struct ModelData: Codable {
    let data: ModelCodingData
    let type: ModelType
}

extension ModelData {
    static var current: ModelData? {
        get {
            guard let data = UserDefaults.standard.object(forKey: UserDefaultsKeys.currentModelKey) as? Data else {
                return nil
            }
            let decoder = JSONDecoder()
            let model = try? decoder.decode(ModelData.self, from: data)
            return model
        }
        set {
            let jsonEncoder = JSONEncoder()
            if let jsonData = try? jsonEncoder.encode(newValue) {
                UserDefaults.standard.set(jsonData, forKey: UserDefaultsKeys.currentModelKey)
            }
        }
    }
}

extension ModelData {
    static var testGroup: Self {
        ModelData(
            data: ModelCodingData(
                id: 15861,
                name: "А101-21",
                slug: "a101-21",
                uuid: UUID(uuidString: "e8b20247-b0a5-4dfc-bf27-da3747038ef5")!
            ),
            type: .group
        )
    }
}
