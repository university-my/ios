//
//  WhatsNewOneSixThree.swift
//  My University
//
//  Created by Yura Voevodin on 01.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct WhatsNewView: View {
    
    var continueAction: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 120, height: 120)
                
                Text("Welcome")
                    .font(.largeTitle)
                    .padding(.vertical)
                
                Text("Thank you for using this app! ❤️")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                Divider()
                    .padding(.all)
                
                Text("Check out what's new in this version:")
                    .font(.headline)
                    .padding(.vertical)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("New design of all universities screen")
                    .font(.body)
                    .fontWeight(.light)
                
                Text("New navigation throughout the app")
                    .font(.body)
                    .fontWeight(.light)
            }
        }
        if let continueAction {
            Button("Continue") {
                continueAction()
            }
            .padding(.vertical)
            .buttonStyle(GradientButton())
        }
    }
}



struct WhatsNewOneSixThree_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView()
    }
}
