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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Website")) {
                    Link(destination: URL.myUniversity) {
                        Label("my-university.com.ua", systemImage: "safari")
                    }
                }
                
                Section(header: Text("Documents")) {
                    NavigationLink {
                        LegalDocumentView(documentName: LegalDocument.privacyPolicy)
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    NavigationLink {
                        LegalDocumentView(documentName: LegalDocument.termsOfService)
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
                
//                Section(header: Text("What's new")) {
//                    NavigationLink {
//                        WhatsNewView()
//                    } label: {
//                        Label("Check out what's new", systemImage: "gift")
//                            .symbolRenderingMode(.multicolor)
//                    }
//                }
                
                Section(header: Text("Feedback")) {
                    Button {
                        UIApplication.shared.open(.contacts)
                    } label: {
                        Label {
                            Text("Report a problem")
                        } icon: {
                            Image(systemName: "ladybug").foregroundColor(.red)
                        }
                    }
                }
                
                if let university = model.university {
                    Section(header: Text("University")) {
                        UniversityView(university: university)
                        Button("Change university") {
                            model.changeUniversity()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(model: InformationViewModel(university: University.CodingData.sumdu))
    }
}

private extension University.CodingData {
    static var sumdu: Self {
        University.CodingData(
            id: 1,
            fullName: "Сумський державний університет",
            shortName: "СумДУ",
            logoLight: "1_light.png",
            logoDark: "1_dark.png"
        )
    }
}
