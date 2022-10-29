//
//  SearchView.swift
//  My University
//
//  Created by Yura Voevodin on 21.07.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @StateObject var model: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            SearchContentView(model: model)
                .listStyle(.plain)
                .navigationTitle("Search")
                .searchable(text: $model.searchText, prompt: "Group, Teachers, Classrooms")
                .searchScopes($model.searchScope) {
                    Text("Groups").tag(ModelType.group)
                    Text("Teachers").tag(ModelType.teacher)
                    Text("Classrooms").tag(ModelType.classroom)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                })
        }
    }
}

struct SearchContentView: View {
    @StateObject var model: SearchViewModel
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        switch model.state {
            
        case let .failed(error):
            ErrorView(error: error, retryAction: {
                Task {
                    await model.fetchData()
                }
            })
            
        case .loading:
            ProgressView()
                .tint(.indigo)
            
        case .presenting:
            List(model.data, id: \.id, selection: $model.selectedID) { item in
                Text(item.name)
            }
            .onChange(of: isSearching) { newValue in
                if !newValue { dismiss() }
            }
            
        default:
            EmptyView()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SearchViewModel()
        model.update(with: University.CodingData.first)
        return SearchView(model: model)
    }
}

private extension University.CodingData {
    static var first: Self {
        University.CodingData(
            id: 1,
            fullName: "First University Full Very Long Name Name",
            shortName: "First Short Name",
            url: "sumdu",
            logoLight: "1_light.png",
            logoDark: "1_dark.png"
        )
    }
}
