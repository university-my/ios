//
//  ErrorView.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text(error.localizedDescription)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .padding()
            
            VStack {
                Button("error_view.retry") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                
                Link("error_view.contact_support",
                     destination: URL.contacts)
                .tint(.indigo)
                .padding(.vertical)
            }
            .padding(.vertical)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: URLError(.badServerResponse), retryAction: {})
    }
}
