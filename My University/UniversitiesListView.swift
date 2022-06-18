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
                List(data, id: \.id, selection: $model.selectedID) { item in
                    UniversityView(university: item)
                }
                .searchable(text: $model.searchText)
                
            case .loading:
                ProgressView()
                    .tint(.indigo)
                
            case let .failed(error):
                ErrorView(
                    error: error,
                    retryAction: {
                        Task {
                            await model.fetchUniversities()
                        }
                    })
                
            default:
                EmptyView()
            }
        }
        .task {
            await model.fetchUniversities()
        }
    }
}

struct UniversitiesListView_Previews: PreviewProvider {
    static var previews: some View {
        UniversitiesListView(model: UniversitiesListViewModel())
    }
}
