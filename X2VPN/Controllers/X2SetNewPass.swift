// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2SetNewPass: UIViewController {

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confPassView: UIView!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfPass: UITextField!
    @IBOutlet weak var btnShow1: UIButton!
    @IBOutlet weak var btnShow2: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        lblStatus.isHidden = true
        loader.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        passwordView.layer.cornerRadius = 10
        confPassView.layer.cornerRadius = 10
        btnSave.layer.cornerRadius = 10
    }

    @IBAction func saveTapped() {
        view.endEditing(true)
        lblStatus.isHidden = true
        let password = tfPassword.text!
        let confPassword = tfConfPass.text!

        if password.isEmpty || password.count < 6 {
            lblStatus.isHidden = false
            lblStatus.text = "Password can not be less than 6 digits"
            return
        }

        if password != confPassword {
            lblStatus.isHidden = false
            lblStatus.text = "Passwords do not match"
            return
        }

        let email = UserDefaults.standard.string(forKey: "userEmail2")
        let otp = UserDefaults.standard.string(forKey: "forgetOtp")

        if(APIManager.shared.checkInternetAvailable()){
            startLoader()
            APIManager.shared.callNewPassAPI(username: email!, password: password, token: otp!, password_confirmation: confPassword, completion: { (result, message) in
                self.stopLoader()
                if(result == "Success"){
                    self.gotoConfirmation()
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

    func gotoConfirmation() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2PasswordConfirmation")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func show1Tapped() {
        if(tfPassword.isSecureTextEntry){
            btnShow1.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow1.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfPassword.isSecureTextEntry.toggle()
    }

    @IBAction func show2Tapped() {
        if(tfConfPass.isSecureTextEntry){
            btnShow2.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow2.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfConfPass.isSecureTextEntry.toggle()
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
