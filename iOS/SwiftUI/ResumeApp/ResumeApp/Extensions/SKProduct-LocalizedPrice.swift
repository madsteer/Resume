//
//  SKProduct-LocalizedPrice.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/20/23.
//

import StoreKit

extension SKProduct {
    /// Localize the price so the user will see the correct price for their country
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
