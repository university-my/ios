//
//  LegalDocumentView.swift
//  My University
//
//  Created by Yura Voevodin on 02.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct LegalDocumentView: View {
    
    let documentName: String
    
    var body: some View {
        LegalDocumentController(documentName: documentName)
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        LegalDocumentView(documentName: LegalDocument.termsOfService)
    }
}
