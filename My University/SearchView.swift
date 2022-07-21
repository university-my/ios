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
        Text("Hello, World!")
            .task {
                await model.fetchAll()
            }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(model: SearchViewModel())
    }
}
