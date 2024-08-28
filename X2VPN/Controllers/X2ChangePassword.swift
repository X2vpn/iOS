// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2ChangePassword: UIViewController {

    @IBOutlet weak var tfCurrentPass: UITextField!
    @IBOutlet weak var tfNewPass: UITextField!
    @IBOutlet weak var tfConfirmPass: UITextField!
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var btnShow1: UIButton!
    @IBOutlet weak var btnShow2: UIButton!
    @IBOutlet weak var btnShow3: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var loader:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        currentView.layer.cornerRadius = 10
        newView.layer.cornerRadius = 10
        confirmView.layer.cornerRadius = 10
        btnSave.layer.cornerRadius = 10
    }

    @IBAction func show1Tapped() {
        if(tfCurrentPass.isSecureTextEntry){
            btnShow1.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow1.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfCurrentPass.isSecureTextEntry.toggle()
    }

    @IBAction func show2Tapped() {
        if(tfNewPass.isSecureTextEntry){
            btnShow2.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow2.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfNewPass.isSecureTextEntry.toggle()
    }

    @IBAction func show3Tapped() {
        if(tfConfirmPass.isSecureTextEntry){
            btnShow3.setImage( UIImage( named: "x2IconHide" ), for: .normal )
        }else{
            btnShow3.setImage( UIImage(named: "x2IconShow" ), for: .normal )
        }
        tfConfirmPass.isSecureTextEntry.toggle()
    }

    @IBAction func backTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

    @IBAction func saveTapped() {
        view.endEditing(true)
        let savedPass = UserDefaults.standard.string(forKey: "password")
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")

        let currentPass = tfCurrentPass.text!
        let newPass = tfNewPass.text!
        let confPass = tfConfirmPass.text!

        if savedPass != currentPass {
            showToast(message: "Current password does not match")
            return
        }

        if newPass.count < 6 {
            showToast(message: "Password can not be less than six digits")
            return
        }

        if newPass != confPass {
            showToast(message: "Password do not match")
            return
        }

        if(APIManager.shared.checkInternetAvailable()){
            startLoader()
            APIManager.shared.callNewPassAPI(username: userEmail!, oldPassword: savedPass!, newPassword: confPass, completion: { [self] (result, message) in
                self.stopLoader()
                if(result == "Success"){
                    self.showToast(message: message)
                    tfNewPass.text = nil
                    tfConfirmPass.text = nil
                    tfCurrentPass.text = nil
                }else{
                    self.showToast(message: message)
                }
            })
        }else{
            showToast(message: "Please Check Your Internet")
        }
    }

    @IBAction func forgetTapped() {
        UserDefaults.standard.set(true, forKey: "fromMenu")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2ForgetPass")
            vc.modalPresentationStyle = .overFullScreen
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
