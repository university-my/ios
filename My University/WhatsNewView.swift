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
            // Logo
            Spacer()
            Image("Logo").resizable().frame(width: 120, height: 120, alignment: .center)

            // Welcome text
            Text("Welcome").font(.largeTitle)
            Text("Thank you for using this app! ❤️").font(.subheadline)
            Spacer()

            // What's new
            VStack() {
                Text("Check out what's new in this version:").font(.headline).padding()
                
                VStack(alignment: .leading, spacing: 5) {

                    // iOS 14
                    iOS14()
                    Divider()

                    // New menus
                    iOS14NewMenus()
                    Divider()
                    
                    // New calendar
                    iOS14NewCalendar()
                    Divider()

                }.padding(.horizontal, 20.0)
            }.padding(10)

            Spacer()

            // Continue
            Button(action: { self.continueAction?() }) {
                ContinueButtonContent()
            }.padding()
        }
    }
    
    fileprivate func iOS14() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("whats_new.support_iOS_14").bold()
        }
        .frame(height: 50)
    }
    
    fileprivate func iOS14NewMenus() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("whats_new.new_menus").bold()
        }
        .frame(height: 50)
    }
    
    fileprivate func iOS14NewCalendar() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("whats_new.new_calendar").bold()
        }
        .frame(height: 50)
    }
}

struct WhatsNewOneSixThree_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView()
    }
}
