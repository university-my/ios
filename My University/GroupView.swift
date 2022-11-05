//
//  GroupView.swift
//  My University
//
//  Created by Yura Voevodin on 28.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    @StateObject var model: GroupViewModel
    
    var body: some View {
        VStack {
            switch model.state {
                
            case .presenting:
                GroupContentView(records: model.recordsList.records)
                
            case .loading:
                ProgressView().tint(.indigo)
                
            case let .failed(error):
                ErrorView(error: error, retryAction: {
                    Task {
                        await model.fetchData()
                    }
                })
            default:
                EmptyView()
            }
        }
        .task {
            await model.fetchData()
        }
    }
}

struct GroupContentView: View {
    var records: [Record.CodingData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            List {
                ForEach(records) { record in
                    Section {
                        VStack(alignment: .leading) {
                            if let name = record.name {
                                Text(name)
                                    .font(.body)
                            }
                            if let type = record.type {
                                Text(type)
                                    .font(.footnote)
                                    .fontWeight(.light)
                            }
                        }
                    } header: {
                        Text(record.sectionName)
                    }
                }
            }
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ModelData(
            data: ModelCodingData(
                id: 15861,
                name: "А101-21",
                slug: "a101-21",
                uuid: UUID(uuidString: "e8b20247-b0a5-4dfc-bf27-da3747038ef5")!
            ),
            type: .group
        )
        return GroupView(model: GroupViewModel(
            model: model,
            university: University.CodingData.testData
        ))
    }
}
