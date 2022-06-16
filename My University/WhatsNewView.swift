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
        VStack {
            Spacer()
            Image("Logo").resizable().frame(width: 120, height: 120, alignment: .center)

            // Welcome text
            VStack(spacing: 5.0) {
                Text("Welcome").font(.largeTitle)
                Text("Thank you for using this app! ❤️").font(.subheadline).fontWeight(.light)
            }
            
            Spacer()

            // What's new
            VStack() {
                Text("Check out what's new in this version:").font(.headline).padding()
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack(alignment: .center, spacing: 10) {
                        Text("whats_new.universities_new_design").bold()
                    }
                    .frame(height: 50)

                }.padding(.horizontal, 20.0)
            }.padding(10)

            Spacer()
            
            Button("Continue") { self.continueAction?() }
                .padding(.bottom)
                .buttonStyle(GradientButton())
        }
    }
}



struct WhatsNewOneSixThree_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView()
    }
}
