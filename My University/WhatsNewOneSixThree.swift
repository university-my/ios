//
//  WhatsNewOneSixThree.swift
//  My University
//
//  Created by Yura Voevodin on 01.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct WhatsNewOneSixThree: View {

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
                Text("Check out what's new in this version:").font(.headline)
                VStack(alignment: .leading, spacing: 5) {

                    // Privacy Policy
                    privacyPolicy()
                    Divider()

                    // Terms of Service
                    termsOfService()
                    Divider()

                    // Patreon
                    patreon()
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

    // MARK: - Privacy Policy

    @State var privacyPolicyModal: Bool = false

    fileprivate func privacyPolicy() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("Privacy Policy").bold()
            Spacer()
            Image(systemName: "info.circle").foregroundColor(.blue)
        }
        .frame(height: 50)
        .sheet(isPresented: $privacyPolicyModal) {
            LegalDocumentView(documentName: LegalDocument.privacyPolicy) {
                // Continue
                self.privacyPolicyModal = false
            }
        }
        .gesture(TapGesture().onEnded { _ in
            self.privacyPolicyModal = true
        })
    }

    // MARK: - Terms of Service

    @State var termsOfServideModal: Bool = false

    fileprivate func termsOfService() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("Terms Of Service").bold()
            Spacer()
            Image(systemName: "info.circle").foregroundColor(.blue)
        }
        .frame(height: 50)
        .sheet(isPresented: $termsOfServideModal) {
            LegalDocumentView(documentName: LegalDocument.termsOfService) {
                // Continue
                self.termsOfServideModal = false
            }
        }
        .gesture(TapGesture().onEnded { _ in
            self.termsOfServideModal = true
        })
    }

    // MARK: - Patreon

    fileprivate func patreon() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("Support on ") + Text("Patreon").bold()
            Spacer()
            Image(systemName: "info.circle").foregroundColor(.blue)
        }
        .frame(height: 50)
        .gesture(TapGesture().onEnded { _ in
            if let parteonURL = URL(string: "https://www.patreon.com/my_university") {
                UIApplication.shared.open(parteonURL)
            }
        })
    }
}

struct WhatsNewOneSixThree_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewOneSixThree()
    }
}
