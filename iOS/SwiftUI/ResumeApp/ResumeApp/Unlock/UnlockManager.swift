//
//  UnlockManager.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/19/23.
//

import Combine
import StoreKit

/// An environment singleton to handle all aspects of in-app purchases for the application
class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    /// Various states that an in-app purchase can be in.
    enum RequestState {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchased
        case deferred
    }

    /// Types of in-app purchase errors we want to track
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    @Published var requestState = RequestState.loading

    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    /// Initializes an unlock manager for the app to use for in-app purchase.
    /// - Parameter dataController: The dataController singleton it will need for certain backend concerns
    init(dataController: DataController) {
        self.dataController = dataController

        // the productID needs to match what is configured in the storekit config
        let productIDs = Set(["com.madsteer.ResumeApp.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        super.init()

        SKPaymentQueue.default().add(self)

        guard dataController.fullVersionUnlocked == false else { return }
        request.delegate = self
        request.start()
    }

    // It's critical that we stop listening for AppStore messages so Apple will queue them
    // up until the next time we start up
    deinit {
        SKPaymentQueue.default().remove(self)
    }

    /// Receive payment requests from the Apple payment queue and process them
    /// - Parameters:
    ///   - queue: an SKPaymentQueue that the transactions are in.
    ///   - transactions: an array of SKPaymentTransactions from Apple
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased

                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }

                    queue.finishTransaction(transaction)

                case .deferred:
                    self.requestState = .deferred

                default:
                    break
                }
            }
        }
    }

    /// After SKProductsRequest finishes successfully to process the products purchased
    /// - Parameters:
    ///   - request: SKProductRequest
    ///   - response: SKProductsResponse containing either success or error information
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.loadedProducts = response.products

            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }

            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            self.requestState = .loaded(unlock)
        }
    }

    /// Tell Apple the user wants to purchase a product
    /// - Parameter product: The SKProduct they want to purchase
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// Restore previous purchases from another device
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
