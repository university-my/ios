//
//  HomeView.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @StateObject var model: HomeViewModel
    
    var body: some View {
        if let university = model.university {
            Text(university.fullName)
        } else {
            Button {
                model.selectUniversity()
            } label: {
                Label("Select University", systemImage: "magnifyingglass")
            }
            .buttonStyle(GradientButton())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}