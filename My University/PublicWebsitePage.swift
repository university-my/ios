//
//  PublicWebsitePage.swift
//  My University
//
//  Created by Yura Voevodin on 09.10.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import Foundation

protocol PublicWebsitePage {
    static var entityPath: String { get }
}

extension PublicWebsitePage {
    
    static func websitePage(from params: WebsitePageParameters) -> Endpoint<EndpointKinds.Public> {
        Endpoint<EndpointKinds.Public>(
            path: "/universities/\(params.university)/\(entityPath)/\(params.slug)",
            queryItems: [
                URLQueryItem(name: "pair_date", value: params.date)
            ]
        )
    }
}
