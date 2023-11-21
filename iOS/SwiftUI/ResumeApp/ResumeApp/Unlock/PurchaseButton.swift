//
//  PurchaseButton.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/20/23.
//

import SwiftUI

/// Special button style for in-app purchase related buttons
struct PurchaseButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 200, maxHeight: 44)
            .background(Color("Light Blue"))
            .clipShape(Capsule())
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
