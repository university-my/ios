//
//  InformationView.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct InformationView: View {
    @StateObject var model: InformationViewModel
    
    var body: some View {
        Form {
            Section(header: Text("University")) {
                Button("Change university") {
                    model.changeUniversity()
                }
            }
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(model: InformationViewModel())
    }
}
