//
//  ProductView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/20/23.
//

import StoreKit
import SwiftUI

struct ProductView: View {
    @EnvironmentObject var unlockManager: UnlockManager
    let product: SKProduct

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Get Unlimited Issues")
                    .font(.headline)
                    .padding(.top, 10)

                Text("You can add three issues for free, or pay \(product.localizedPrice) to add unlimited issues.")

                Text("If you already bought the unlock on another device, press Restore Purchases.")

                Button("Buy: \(product.localizedPrice)", action: unlock)
                    .buttonStyle(PurchaseButton())

                Button("Restore Purchases", action: unlockManager.restore)
                    .buttonStyle(PurchaseButton())
            }
        }
    }

    // helper method so unlock can be called from the button above
    func unlock() {
        unlockManager.buy(product: product)
    }
}

// #Preview {
//    ProductView()
// }
