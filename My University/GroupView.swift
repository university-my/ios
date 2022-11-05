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
                GroupContentView(model: model)
                
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
    @StateObject var model: GroupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("Управління науковими проектами")
                            .font(.body)
                        Text("Лекція")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                } header: {
                    Text("1 ПАРА (08:00-09:20)")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Управління науковими проектами")
                            .font(.body)
                        Text("Лекція")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                } header: {
                    Text("2 ПАРА (09:40-11:00)")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Управління науковими проектами")
                            .font(.body)
                        Text("Лекція")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                } header: {
                    Text("3 ПАРА (11:20-12:40)")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Управління науковими проектами")
                            .font(.body)
                        Text("Лекція")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                } header: {
                    Text("5 ПАРА (14:00-15:20)")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Тест")
                            .font(.body)
                    }
                } header: {
                    Text("6 ПАРА")
                }
            }
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ModelData(
            data: ModelCodingData(id: 1, name: "Test", slug: "test", uuid: UUID()),
            type: .group
        )
        return GroupView(model: GroupViewModel(
            model: model,
            university: University.CodingData.testData
        ))
    }
}
