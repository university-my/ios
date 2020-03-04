//
//  LegalDocumentView.swift
//  My University
//
//  Created by Yura Voevodin on 02.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct LegalDocumentView: View {

    var documentName: String
    var continueAction: (() -> ())?

    fileprivate func legalDocumentController() -> some View {
        let controller = LegalDocumentViewController()
        controller.documentName = documentName
        return controller
    }

    var body: some View {
        VStack {
            // Document
            legalDocumentController()

            // Continue
            Button(action: { self.continueAction?() }) {
                ContinueButtonContent()
            }.padding()
        }
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        LegalDocumentView(documentName: LegalDocument.termsOfService)
    }
}
