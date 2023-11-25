//
//  StoreView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/24/23.
//

import StoreKit
import SwiftUI

struct StoreView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var products = [Product]()

    var body: some View {
        NavigationStack {
            if let product = products.first {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.title)

                    Text(product.description)

                    Button("Buy Now") {
                        purchase(product)
                    }
                }
            }
        }
        .onChange(of: dataController.fullVersionUnlocked) { _ in
            checkForPurchase()
        }
        .task {
            await load()
        }
    }

    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }

    func purchase(_ product: Product) {
        Task { @MainActor in
            try await dataController.purchase(product)
        }
    }

    func load() async {
        do {
            products = try await Product.products(for: [DataController.unlockPremiumProductID])
        } catch {
            print("Error loading products: \(error.localizedDescription)")
        }
    }
}

#Preview {
    StoreView()
}
