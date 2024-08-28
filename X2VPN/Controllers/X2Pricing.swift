// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit
import StoreKit

class X2Pricing: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var loader:UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    private var inAppArray = [SKProduct]()
    private var productArray = [InAppVPN]()
    private var userData: User!
    private var receipt: Receipt!
    private let defaults = UserDefaults.standard

    //    var selectedProduct: SKProduct? = StoreManager.shared.getInAppProductList().last ?? nil

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self

        updateUI()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: NSNotification.Name("RefreshInApp"), object: nil)
    }

    @objc func updateUI() {


        let delegate = UIApplication.shared.delegate as? AppDelegate
        let userData = delegate?.getuserData()

        self.productArray = (userData?.inAppData?.inAppPackages)!
        self.inAppArray = StoreManager.shared.getRegularInAppProductList()
        self.tableView.reloadData()
    }

    @IBAction func backTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

    func startLoader() {
        loader.startAnimating()
        loader.isHidden = false
    }

    func stopLoader() {
        loader.stopAnimating()
        loader.isHidden = true
    }

    @IBAction func restoreButtonTapped(){
        startLoader()
        StoreManager.shared.restorePurchase(completion: {result, message, receipt in
            self.stopLoader()

            if(result == "IAPResultCodeSuccess"){
                APIManager.shared.callPaymentAPI(userName: receipt!.userID, userEmail: "", receipt: receipt!.receiptData, completion: {response in
                    if(response == "Success"){
                        self.showToast(message: response)
                        DispatchQueue.main.async {
                            self.dismiss(animated: false)
                        }
                    }else{
                        self.showToast(message: response)
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        var array = delegate?.getLocalReceiptData() ?? [Receipt]()
                        array.append(receipt!)
                        delegate?.saveLocalReceiptData(data: array)
                        UserDefaults.standard.set(false, forKey: "PurchaseInProgress")
                    }
                })
            }else if(result == "IAPResultCodeNull"){
                self.showToast(message: "You have no subscriptions to restore!")
            }else{
                self.showToast(message: message)
                UserDefaults.standard.set(false, forKey: "PurchaseInProgress")
            }
        })
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inAppArray.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CellForPrice") as! CellForPrice
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let userData = delegate?.getuserData()

        productArray = (userData?.inAppData?.inAppPackages)!
        inAppArray = StoreManager.shared.getRegularInAppProductList()

        print("inapp count: ", productArray.count, inAppArray.count)

        let item = inAppArray[indexPath.row]

        cell.lblTitle.text = item.localizedTitle
        cell.lblPrice.text = item.localizedPrice
        cell.lblOffer.text = productArray[indexPath.row].highlightedText

        if cell.lblOffer.text == "" {
            cell.offerView.isHidden = true
        }

        cell.offerView.layer.cornerRadius = 6
        cell.rootView.layer.cornerRadius = 10

        if item.productIdentifier == defaults.string(forKey: "productIdentifier-\(defaults.string(forKey: "userEmail") ?? "")") {
            cell.rootView.backgroundColor = UIColor(named: "763DFF")
            cell.lblPrice.textColor = UIColor(named: "FAF5FF")
            cell.lblTitle.textColor = UIColor(named: "FAF5FF")
        } else {
            cell.rootView.backgroundColor = UIColor(named: "FAF5FF")
            cell.lblPrice.textColor = UIColor(named: "000000")
            cell.lblTitle.textColor = UIColor(named: "000000")
        }

        cell.priceTapped = { [self] in
            defaults.set(self.inAppArray[indexPath.row].productIdentifier, forKey: "productIdentifier-\(defaults.string(forKey: "userEmail") ?? "")")
            self.tableView.reloadData()
            //            self.callConnectionTask()

            confirmButtonTapped(productID:inAppArray[indexPath.row].productIdentifier)
        }

        return cell
    }

    func confirmButtonTapped(productID: String){
        if(!APIManager.shared.checkInternetAvailable()){
            self.showToast(message: "Please Check Your Internet")
            return
        }

        startLoader()
        UserDefaults.standard.set(true, forKey: "PurchaseInProgress")
        StoreManager.shared.purchaseProduct(productID: productID, completion : {(result, message, receipt) in
            print("\(result) : \(message)")
            if(result == "IAPResultCodeSuccess"){
                APIManager.shared.callPaymentAPI(userName: receipt!.userID, userEmail: "", receipt: receipt!.receiptData, completion: {response in
                    if(response == "Success"){
                        self.showToast(message: "Purchase successful")
                        APIManager.shared.refreshUserData()
                        DispatchQueue.main.async {
                            self.dismiss(animated: false)
                        }
                    }else{
                        self.stopLoader()
                        self.showToast(message: response)
                        // Save Receipt In UserDefault For Validate Later
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        var array = delegate?.getLocalReceiptData() ?? [Receipt]()
                        array.append(receipt!)
                        delegate?.saveLocalReceiptData(data: array)
                        UserDefaults.standard.set(false, forKey: "PurchaseInProgress")
                    }
                })
            }else{
                self.stopLoader()
                self.showToast(message: message)
                UserDefaults.standard.set(false, forKey: "PurchaseInProgress")
            }
        })
    }
}
