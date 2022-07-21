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
    
    var body: some View {
        VStack {
            switch model.state {
                
            case let .failed(error):
                ErrorView(
                    error: error,
                    retryAction: {
                        Task {
                            await model.fetchAll()
                        }
                    })
                
            case .loading:
                ProgressView()
                    .tint(.indigo)
                
            case .presenting:
                NavigationStack {
                    List(model.data, id: \.id, selection: $model.selectedID) { item in
                        Text(item.name)
                    }
                    .listStyle(.plain)
                    .navigationTitle("Search")
                    .searchable(text: $model.searchText, prompt: "Group, Teachers, Classrooms")
                    .searchScopes($model.searchScope) {
                        Text("Groups").tag(SearchScope.groups)
                        Text("Teachers").tag(SearchScope.teachers)
                        Text("Classrooms").tag(SearchScope.classrooms)
                    }
                }
                
            default:
                EmptyView()
            }
        }
        .task {
            await model.fetchAll()
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
