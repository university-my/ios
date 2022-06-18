//
//  UniversitiesListView.swift
//  My University
//
//  Created by Yura Voevodin on 17.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct UniversitiesListView: View {
    
    @StateObject var model: UniversitiesListViewModel
    
    var body: some View {
        VStack {
            switch model.state {
                
            case let .presenting(data):
                List {
                    ForEach(data, id: \.id) { item in
                        UniversityView(university: item)
                    }
                }
                
            case .loading:
                ProgressView()
                
            default:
                EmptyView()
            }
        }
        .task {
            await model.fetchUniversities()
        }
        .searchable(text: $model.searchText)
        .navigationTitle("Test 2")
        .toolbar {
            Button("Hello") {
                print("111")
            }
        }
    }
}

struct UniversitiesListView_Previews: PreviewProvider {
    static var previews: some View {
        UniversitiesListView(model: UniversitiesListViewModel(dataProvider: UniversitiesListDataProvider(networkClient: UniversitiesListNetworkClient())))
    }
}
