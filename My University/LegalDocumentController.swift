//
//  LegalDocumentController.swift
//  My University
//
//  Created by Yura Voevodin on 11.12.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

struct LegalDocumentController: UIViewControllerRepresentable {
    
    let documentName: String
    
    func makeUIViewController(context: Context) -> LegalDocumentViewController {
        let storyboard = UIStoryboard.legalDocument
        let controller = storyboard.instantiateInitialViewController() as! LegalDocumentViewController
        controller.documentName = documentName
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LegalDocumentViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = LegalDocumentViewController
}
