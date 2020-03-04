//
//  LegalDocumentViewController.swift
//  My University
//
//  Created by Yura Voevodin on 08.02.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import UIKit
import SwiftUI

final class LegalDocumentViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        if let name = documentName {
            showDocument(with: name)
        }
        // Prevent UITextView from appearing under the navigation bar
        textView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Text View

    var documentName: String?

    @IBOutlet weak var textView: UITextView!

    private func showDocument(with name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "rtf") else { return }
        do {
            // Reading the file
            let data = try Data(contentsOf: url)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
            let text = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)

            // Attributes
            let range = NSRange(location: 0, length: text.mutableString.length)
            text.addAttribute(.foregroundColor, value: UIColor.label, range: range)

            // Applying
            textView.attributedText = text

        } catch {}
    }
}

// MARK: - UIViewControllerRepresentable

extension LegalDocumentViewController: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<LegalDocumentViewController>) -> LegalDocumentViewController {
        let storyboard = UIStoryboard.legalDocument()
        let controller = storyboard.instantiateInitialViewController() as! LegalDocumentViewController
        controller.documentName = documentName
        return controller
    }

    func updateUIViewController(_ uiViewController: LegalDocumentViewController, context: UIViewControllerRepresentableContext<LegalDocumentViewController>) {

    }

    typealias UIViewControllerType = LegalDocumentViewController
}
