// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit
import UICKeyChainStore

class X2Login: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnShow: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        lblStatus.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        btnLogin.layer.cornerRadius = 10
        emailView.layer.cornerRadius = 10
        passwordView.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let keychain = UICKeyChainStore(service: "X2VPN")
        tfEmail.text = keychain.string(forKey: "userEmail")
        tfPassword.text = keychain.string(forKey: "password")
    }

    @IBAction func showHideTapped() {
        if(tfPassword.isSecureTextEntry){
            btnShow.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfPassword.isSecureTextEntry.toggle()
    }

    @IBAction func loginButtonTapped() {
        lblStatus.isHidden = true
        if(APIManager.shared.checkInternetAvailable()){
            callLoginApi()
        } else {
            lblStatus.text = "No internet available. Check network connections."
            lblStatus.isHidden = false
        }

    }

    func callLoginApi() {
        let userEmail = tfEmail.text!
        let password = tfPassword.text!

        if userEmail.isEmpty {
            lblStatus.text = "User Name/Email can not be empty"
            lblStatus.isHidden = false
            return
        }

        if password.isEmpty {
            lblStatus.text = "Password can not be empty"
            lblStatus.isHidden = false
            return
        }

        startLoader()
        APIManager.shared.loginAPI(userEmail: userEmail, password: password, completion: { (result, message) in
            self.stopLoader()
            if(result == "Success"){
                self.gotoNextView()
            }else if (result == "Not Verified"){
                self.showToast(message: message)

                UserDefaults.standard.set(userEmail, forKey: "userEmail")

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.gotoVerification()
                }

            } else {
                DispatchQueue.main.async {
                    self.lblStatus.text = message
                    self.lblStatus.isHidden = false
                }
            }
        })
    }

    func gotoNextView() {
        UserDefaults.standard.set(true, forKey: "loggedIn")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2TabBar")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func forgetPasswordTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2ForgetPass")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func createAccountTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2CreateAccount")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
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
