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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            switch model.state {
                
            case let .presenting(data):
                NavigationStack {
                    List(data, id: \.id, selection: $model.selectedID) { item in
                        UniversityView(university: item)
                    }
                    .navigationTitle("Universities")
                    .searchable(text: $model.searchText)
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            dismiss()
                        }
                    )
                }
                
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
