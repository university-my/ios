//
//  UniversityView.swift
//  My University
//
//  Created by Yura Voevodin on 16.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct UniversityView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let university: University.CodingData
    
    var body: some View {
        HStack(spacing: 8.0) {
            if let imageURL = university.logo(for: colorScheme) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                        
                    case .empty:
                        ProgressView()
                        
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                        
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(Color.gray)
                        
                    @unknown default:
                        // Since the AsyncImagePhase enum isn't frozen,
                        // we need to add this currently unused fallback
                        // to handle any new cases that might be added
                        // in the future:
                        EmptyView()
                    }
                }.frame(width: 50, height: 50)
            }
            VStack(alignment: .leading, spacing: 8.0) {
                Text(university.shortName)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                Text(university.fullName)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
            }
        }
        .padding(.vertical)
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct UniversityView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            UniversityView(university: University.CodingData.first)
            UniversityView(university: University.CodingData.second)
            UniversityView(university: University.CodingData.third)
        }
    }
}

private extension University.CodingData {
    static var first: Self {
        University.CodingData(
            id: 1,
            fullName: "First University Full Very Long Name Name",
            shortName: "First Short Name",
            logoLight: "1_light.png",
            logoDark: "1_dark.png"
        )
    }
    
    static var second: Self {
        University.CodingData(
            id: 2,
            fullName: "Second University Full Very Long Name Name",
            shortName: "Second Short Name",
            logoLight: "",
            logoDark: ""
        )
    }
    
    static var third: Self {
        University.CodingData(
            id: 3,
            fullName: "Third University Full Very Long Name",
            shortName: "Third Short Name",
            logoLight: nil,
            logoDark: nil
        )
    }
}
