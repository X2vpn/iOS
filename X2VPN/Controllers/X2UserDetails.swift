// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2UserDetails: UIViewController {

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPassView: UIView!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPass: UITextField!
    @IBOutlet weak var btnShow2: UIButton!
    @IBOutlet weak var btnShow3: UIButton!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        lblStatus.isHidden = true
        loader.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        nameView.layer.cornerRadius = 10
        passwordView.layer.cornerRadius = 10
        confirmPassView.layer.cornerRadius = 10
        btnCreateAccount.layer.cornerRadius = 10
    }

    @IBAction func show2Tapped() {
        if(tfPassword.isSecureTextEntry){
            btnShow2.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow2.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfPassword.isSecureTextEntry.toggle()
    }

    @IBAction func show3Tapped() {
        if(tfConfirmPass.isSecureTextEntry){
            btnShow3.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow3.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfConfirmPass.isSecureTextEntry.toggle()
    }

    @IBAction func createAccountTapped() {
        view.endEditing(true)
        lblStatus.isHidden = true

        let fullName = tfUserName.text!
        let password = tfPassword.text!
        let confPassword = tfConfirmPass.text!

        if fullName.isEmpty {
            lblStatus.isHidden = false
            lblStatus.text = "Enter full name"
            return
        }

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

        let email = UserDefaults.standard.string(forKey: "userEmail")

        startLoader()

        if(APIManager.shared.checkInternetAvailable()){
            APIManager.shared.callSignUpAPI(email: email!, password: password, fullname: fullName, completion: { (result, message) in
                self.stopLoader()
                if(result == "Success"){
                    self.lblStatus.isHidden = true
                    self.gotoVerification()
                }else{
                    self.lblStatus.isHidden = false
                    self.lblStatus.text = message
                }
            })
        } else {
            startLoader()
            self.lblStatus.isHidden = false
            self.lblStatus.text = "Please Check Your Internet."
        }

    }

    func gotoVerification() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2SignUpOtp")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
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
