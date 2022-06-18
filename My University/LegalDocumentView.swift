//
//  LegalDocumentView.swift
//  My University
//
//  Created by Yura Voevodin on 18.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
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
