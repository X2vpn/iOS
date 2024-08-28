// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2ForgetPass: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var emailview: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForgetPass: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        lblStatus.isHidden = true
        loader.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        emailview.layer.cornerRadius = 10
        btnForgetPass.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "fromMenu") {
            btnBack.setTitle("Go Back", for: .normal)
        } else {
            btnBack.setTitle("Back to Login", for: .normal)
        }

    }

    @IBAction func backTapped() {
        UserDefaults.standard.set(false, forKey: "fromMenu")
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }

    @IBAction func forgetTapped() {
        lblStatus.isHidden = true
        let email = tfEmail.text ?? ""


        if(!isValidEmail(email)){
            lblStatus.isHidden = false
            lblStatus.text = "Email address invalid"
            return
        }

        UserDefaults.standard.setValue(email, forKey: "userEmail2")

        if(APIManager.shared.checkInternetAvailable()){
            startLoader()
            APIManager.shared.callRestPassTokenRequest(username: email, completion: {(result, message) in
                self.stopLoader()
                if(result == "Success"){
                    self.lblStatus.isHidden = true
                    self.goToConfirmPage()
                }else{
                    self.lblStatus.isHidden = false
                    self.lblStatus.text = message
                }
            })
        }else{
            self.lblStatus.isHidden = false
            self.lblStatus.text = "Please Check Your Internet"
        }
    }

    func goToConfirmPage() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2ForgetPassOtp")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        if(email == ""){
            return false
        }else{
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
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

}
