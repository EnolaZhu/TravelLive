//
//  PurchaseManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/15.
//

import StoreKit
class IAPManager: NSObject {
    
    static let shared = IAPManager()
    var products = [SKProduct]()
    fileprivate var productRequest: SKProductsRequest!
func getProductIDs() -> [String] {
        ["removeAd"]
    }
    
    func getProducts() {
        let productIds = getProductIDs()
        let productIdsSet = Set(productIds)
        productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        productRequest.delegate = self
        productRequest.start()
    }
}
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach {
            print($0.localizedTitle, $0.price, $0.localizedDescription)
        }
        self.products = response.products
    }
}
