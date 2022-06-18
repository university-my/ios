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
            Section(header: Text("Website")) {
                Link(destination: URL.myUniversity) {
                    Label("my-university.com.ua", systemImage: "safari")
                }
            }
            
            Section(header: Text("Documents")) {
                NavigationLink {
                    EmptyView()
                } label: {
                    Label("Privacy Policy", systemImage: "lock.shield")
                }
                NavigationLink {
                    EmptyView()
                } label: {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
            
            Section(header: Text("What's new")) {
                NavigationLink {
                    WhatsNewView()
                } label: {
                    Label("Check out what's new", systemImage: "gift")
                        .symbolRenderingMode(.multicolor)
                }
            }
            
            Section(header: Text("Social Networks")) {
                Link(destination: URL(string: "https://www.facebook.com/myuniversityservice")!) {
                    Text("Facebook")
                }
                Link(destination: URL(string: "https://www.instagram.com/university.my")!) {
                    Text("Instagram")
                }
                Link(destination: URL(string: "https://t.me/university_my")!) {
                    Text("Telegram")
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
