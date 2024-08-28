// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.


import Foundation
import UIKit

class X2TabBarProfile: UIViewController {

    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblSubscription: UILabel!
    @IBOutlet weak var lblExpiry: UILabel!
    @IBOutlet weak var lblDeviceCount: UILabel!
    @IBOutlet weak var btnPremium: UIButton!
    private var deviceArray = [Device]()

    override func viewDidLoad() {
        super.viewDidLoad()


        updateUI()
        callDeviceApi()

        NotificationCenter.default.addObserver(self, selector: #selector(callDeviceApi), name: NSNotification.Name("updateDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name("refreshUserData"), object: nil)
    }

    @objc func updateUI() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let userData = delegate?.getuserData()

        lblFullName.text = userData?.fullname
        lblUserName.text = UserDefaults.standard.string(forKey: "userEmail")
        lblSubscription.text = userData?.subscriptionPlanName
        lblExpiry.text = "\("Expired On:") \(userData?.validityDate ?? "Unknown")"

        if userData?.userType == 1 {
            lblStatus.text = "Reseller"
        } else if (userData?.userType == 2) {
            lblStatus.text = "Premium"
        } else {
            lblStatus.text = "Free"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        lblStatus.layer.cornerRadius = self.lblStatus.frame.height/2
        lblStatus.clipsToBounds = true
        btnPremium.layer.cornerRadius = 10
    }

    @objc func callDeviceApi() {
        if(APIManager.shared.checkInternetAvailable()){
            APIManager.shared.getDeviceList(completion: { [self](result, list) in
                if(result == "Success"){
                    deviceArray = list
                    lblDeviceCount.text = "\(list.count)"

                    UserDefaults.standard.set(list.count, forKey: "deviceCount")

//                    print("Device Array count: ", list.count)
                }else{
                    self.showToast(message: result)
                }
            })
        }else{
            self.showToast(message: "Please Check Your Internet")
        }
    }


    @IBAction func priceTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Pricing")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func deviceTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Device")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func changePassTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2ChangePassword")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func feedbackTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Feedback")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func privacyTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2PrivacyPolicy")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func aboutTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2AboutApp")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func deleteTapped() {
        UserDefaults.standard.set(false, forKey: "loggedIn")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2DeleteAccount")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func logoutTapped() {
        UserDefaults.standard.set(false, forKey: "loggedIn")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Login")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

}
