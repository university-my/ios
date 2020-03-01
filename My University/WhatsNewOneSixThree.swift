//
//  WhatsNewOneSixThree.swift
//  My University
//
//  Created by Yura Voevodin on 01.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct WhatsNewOneSixThree: View {

    var dismiss: (() -> Void)?

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome")
                .font(.largeTitle)
            Text("Thank you for using this app! ❤️")
                .font(.subheadline)
            Spacer()

            VStack() {
                Text("Check out what's new in this version:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 5) {
                    Text("New and shiny Privacy Policy")
                    .padding(.top)
                    Divider()
                    Text("New Terms Of Service")
                    Divider()
                    Text("Now you can support this project on Patreon")
                }
                .padding(.horizontal, 10.0)
            }
            .padding(10)

            Spacer()

            // Support on Patreon
            Button(action: {
                if let parteonURL = URL(string: "https://www.patreon.com/my_university") {
                    UIApplication.shared.open(parteonURL)
                    self.dismiss?()
                }
            }) {
                SupportButtonContent()
            }
            .padding(.vertical, 20)

            // Dismiss
            Button(action: {
                self.dismiss?()
            }) {
                Text("Dismiss")
            }
            .padding(.bottom)
        }
    }
}

struct WhatsNewOneSixThree_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewOneSixThree()
    }
}

struct SupportButtonContent: View {
    var body: some View {
        Text("Support on Patreon")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 240, height: 60)
            .background(Color.green)
            .cornerRadius(15)
    }
}
