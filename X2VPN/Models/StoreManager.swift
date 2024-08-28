
import StoreKit
import UICKeyChainStore

class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{

    static let shared = StoreManager()
    private var inAppProducts: [SKProduct]?
    private var completionHandler: ((String, String, Receipt?) -> Void)?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func loadInAppProducts(productList : Set<String>){
        let request = SKProductsRequest(productIdentifiers: Set<String>(productList))
        request.delegate = self
        request.start()
    }

    // In App Product Request Delegate...................................................................................

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if(response.invalidProductIdentifiers.count > 0){
            print("Invalid Product IDs:\(response.invalidProductIdentifiers)")
        }

        if(response.products.count > 0){
            self.inAppProducts = response.products
            self.inAppProducts!.sort(by: { (p0, p1) -> Bool in
                return p0.price.floatValue < p1.price.floatValue
            })
            print("InAppProduct Count : \(self.inAppProducts?.count ?? 0)")
            NotificationCenter.default.post(name: Notification.Name("RefreshInApp"), object: nil)
        }else{
            print("Empty In App Product List")
        }
    }

    // In App Payment Transaction Observer...................................................................................

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Payment Successfull")
                do{
                    let receipt = try Data(contentsOf: Bundle.main.appStoreReceiptURL!)
                    let keychain = UICKeyChainStore(service: "X2VPN")
                    let userID = keychain.string(forKey: "username") ?? ""
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    let userEmail = delegate?.getuserData()?.contactEmail ?? ""
                    let receiptData = Receipt(userID: userID, userEmail: userEmail,  productID: transaction.transactionIdentifier!, receiptData: receipt)
                    if(self.completionHandler != nil){
                        self.completionHandler!("IAPResultCodeSuccess", "Payment Success", receiptData)
                    }
                }catch{
                    if(self.completionHandler != nil){
                        self.completionHandler!("IAPResultCodeFailed", error.localizedDescription, nil)
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                print("Payment Failed")
                if(self.completionHandler != nil){
                    self.completionHandler!("IAPResultCodeFailed", "Payment Failed", nil)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                print("Payment Restored")

//                SKPaymentQueue.default().finishTransaction(transaction)
//
//                do{
//                    let receipt = try Data(contentsOf: Bundle.main.appStoreReceiptURL!)
//                    let keychain = UICKeyChainStore(service: "com.spinytel.X2VPN")
//                    let userID = keychain.string(forKey: "username") ?? ""
//                    let delegate = UIApplication.shared.delegate as? AppDelegate
//                    let userEmail = delegate?.getuserData()?.contactEmail ?? ""
//                    let receiptData = Receipt(userID: userID, userEmail: userEmail,  productID: transaction.transactionIdentifier!, receiptData: receipt)
//                    if(self.completionHandler != nil){
//                        self.completionHandler!("IAPResultCodeSuccess", "Subscription Restored", receiptData)
//                    }
//                }catch{
//                    if(self.completionHandler != nil){
//                        self.completionHandler!("IAPResultCodeSuccess", "Subscription Restored", nil)
//                    }
//                }
//                break
            case .deferred:
                print("Payment Deferred")
                if(self.completionHandler != nil){
                    self.completionHandler!("IAPResultCodeDeferred", "Payment Deferred", nil)
                }
                break
            case .purchasing:
                print("Payment Purchasing")
                break
            @unknown default:
                print("Unknown State")
                if(self.completionHandler != nil){
                    self.completionHandler!("IAPResultCodeUnknown", "Unknown State", nil)
                }
            }
        }
    }

    // In App Helper Functions...............................................................................

    func getInAppProductList() -> [SKProduct]{
        return self.inAppProducts ?? []
    }

    func getRegularInAppProductList() -> [SKProduct]{
//        print("get regular products: ", inAppProducts as Any)
        return self.inAppProducts?.filter({$0.productIdentifier.contains("com.rivernet.x2vpnios")}) ?? []
    }

    func getProductFromID(productID: String) -> SKProduct{
        return (self.inAppProducts?.filter({$0.productIdentifier == productID}).first)!
    }

    func purchaseProduct(productID: String, completion: @escaping (String, String, Receipt?) -> Void){
        self.completionHandler = completion
        if(SKPaymentQueue.canMakePayments()){
            let product = getProductFromID(productID: productID)

            let keychain = UICKeyChainStore(service: "X2VPN")
            let udid = keychain.string(forKey: "UUID") ?? ""

            let payment = SKMutablePayment(product: product)
            payment.applicationUsername =  udid
            SKPaymentQueue.default().add(payment)
        }else{
            completion("IAPResultCodeUserCanceled", "Users are prohibited from using in-app purchases", nil)
        }
    }

    func restorePurchase(completion: @escaping (String, String, Receipt?) -> Void){
        self.completionHandler = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueue",queue.transactions.count)
        if(queue.transactions.count == 0){
            if(self.completionHandler != nil){
                self.completionHandler!("IAPResultCodeNull", "No Subscription Found", nil)
            }
            return
        }
        for transaction in queue.transactions {
            switch transaction.transactionState {
            case .restored:
                do{
                    let receipt = try Data(contentsOf: Bundle.main.appStoreReceiptURL!)
                    let keychain = UICKeyChainStore(service: "X2VPN")
                    let userID = keychain.string(forKey: "username") ?? ""
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    let userEmail = delegate?.getuserData()?.contactEmail ?? ""
                    let receiptData = Receipt(userID: userID, userEmail: userEmail,  productID: transaction.transactionIdentifier!, receiptData: receipt)
                    if(self.completionHandler != nil){
                        self.completionHandler!("IAPResultCodeSuccess", "Subscription Restored", receiptData)
                    }
                }catch{
                    if(self.completionHandler != nil){
                        self.completionHandler!("IAPResultCodeSuccess", "Subscription Restored", nil)
                    }
                }
                break
            default:
                break

            }
        }
        print("paymentQueue: paymentQueueRestoreCompletedTransactionsFinished")
    }
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("paymentQueue: restoreCompletedTransactionsFailedWithError")
        if(self.completionHandler != nil){
            self.completionHandler!("IAPResultCodeFailed", "Payment Failed", nil)
        }
    }
}
