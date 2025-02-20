//
//  PurchaseManager.swift
//  AiKiss
//
//  Created by Владимир Кацап on 10.12.2024.
//

import Foundation
import StoreKit
import Combine
import ApphudSDK
import Alamofire

class PurchaseManager: NSObject {
    
    let paywallID = "main"
    var productsApphud: [ApphudProduct] = []
    
    var hasUnlockedPro: Bool {
        return Apphud.hasPremiumAccess()
    }
    


    @MainActor
    func dateSubscribe() -> String {
        if let subscription = Apphud.subscription() {
            let expirationDate = subscription.expiresDate // Здесь используется напрямую

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let formattedDate = dateFormatter.string(from: expirationDate)
            
            return "until \(formattedDate)"
        }
        
        return "No active subscription"
    }

    
    @MainActor func startPurchase(produst: ApphudProduct, escaping: @escaping(Bool) -> Void) {
        let selectedProduct = produst
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint(error.localizedDescription)
               escaping(false)
            }
            debugPrint(result)
            if let subscription = result.subscription, subscription.isActive() {
                escaping(true)
            } else {
                if Apphud.hasActiveSubscription() {
                    escaping(true)
                } 
            }
        }
    }

    
    @MainActor
    func loadPaywalls(escaping: @escaping() -> Void) {

        Apphud.paywallsDidLoadCallback { paywalls, arg in
           
            if let paywall = paywalls.first(where: { $0.identifier == self.paywallID}) {
                Apphud.paywallShown(paywall)
                
                let products = paywall.products
                self.productsApphud = products
                
                print(products, "Proddd")
                for i in products {
                    print(i.productId, "ID")
                }
                escaping()
            }
        }
    }
    
    @MainActor func restorePurchase(escaping: @escaping(Bool) -> Void) {
        print("restore")
        Apphud.restorePurchases {  subscriptions, _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                escaping(false)
                return
            }
            if subscriptions?.first?.isActive() ?? false {
                escaping(true)
                return
            }
            
            if Apphud.hasActiveSubscription() {
                escaping(true)
                return
            }
            
            escaping(false)
        }
    }
    
}
