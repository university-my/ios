//
//  ContinueButtonContent.swift
//  My University
//
//  Created by Yura Voevodin on 02.03.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct ContinueButtonContent: View {
    var body: some View {
        Text("Continue")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 260, height: 60)
            .background(gradient)
            .cornerRadius(15)
    }

    private var gradient: LinearGradient {
        let gradient = Gradient(colors: [Color(UIColor.cornflowerBlue), .purple])
        return LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
    }
}

struct ContinueButtonContent_Previews: PreviewProvider {
    static var previews: some View {
        ContinueButtonContent()
    }
}
