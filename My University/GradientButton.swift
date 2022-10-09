//
//  GradientButton.swift
//  My University
//
//  Created by Yura Voevodin on 16.06.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct GradientButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(gradient)
            .cornerRadius(15)
    }
    
    private var gradient: LinearGradient {
        let gradient = Gradient(colors: [Color(UIColor.cornflowerBlue), .purple])
        return LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
    }
}
