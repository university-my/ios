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
                
                VStack() {
                    Text("Check out what's new in this version:")
                        .font(.headline)
                        .padding(.vertical)
                    
                    Text("whats_new.universities_new_design")
                        .font(.body)
                        .fontWeight(.light)
                }
                .padding(.horizontal)
            }
        }
        Button("Continue") { self.continueAction?() }
            .padding(.vertical)
            .buttonStyle(GradientButton())
    }
}



struct WhatsNewOneSixThree_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView()
    }
}
