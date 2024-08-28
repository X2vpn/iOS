// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2SignUpOtp: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnConfirm:UIButton!
    @IBOutlet weak var otpView1:UIView!
    @IBOutlet weak var otpView2:UIView!
    @IBOutlet weak var otpView3:UIView!
    @IBOutlet weak var otpView4:UIView!
    @IBOutlet weak var otpText1:UITextField!
    @IBOutlet weak var otpText2:UITextField!
    @IBOutlet weak var otpText3:UITextField!
    @IBOutlet weak var otpText4:UITextField!
    @IBOutlet weak var lblStatus:UILabel!
    @IBOutlet weak var lblEmail:UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()

        loader.isHidden = true
        lblStatus.isHidden = true

        self.otpText1.returnKeyType = UIReturnKeyType.next
        self.otpText2.returnKeyType = UIReturnKeyType.next
        self.otpText3.returnKeyType = UIReturnKeyType.next
        self.otpText4.returnKeyType = UIReturnKeyType.done
        self.otpText1.delegate = self
        self.otpText2.delegate = self
        self.otpText3.delegate = self
        self.otpText4.delegate = self

        let email = UserDefaults.standard.string(forKey: "userEmail")!
        lblEmail.text = "'\(email)'"

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillLayoutSubviews() {
        self.otpView1.layer.cornerRadius = 10
        self.otpView2.layer.cornerRadius = 10
        self.otpView3.layer.cornerRadius = 10
        self.otpView4.layer.cornerRadius = 10
        self.btnConfirm.layer.cornerRadius = 10
    }

//    @IBAction func backTapped() {
//        DispatchQueue.main.async {
//            self.dismiss(animated: false)
//        }
//    }

    @IBAction func submitTapped(){
        view.endEditing(true)
        self.lblStatus.isHidden = true

        if otpText1.text == "" || otpText2.text ==  "" || otpText3.text == "" || otpText4.text == "" {
            self.lblStatus.isHidden = false
            self.lblStatus.text = "Enter 4 digits OTP"
            return
        }

        let captcha = otpText1.text! + otpText2.text! + otpText3.text! + otpText4.text!

        let email = UserDefaults.standard.string(forKey: "userEmail")

        if(APIManager.shared.checkInternetAvailable()){
            startLoader()
            APIManager.shared.callSignUpVerificationAPI(username: email!, token: captcha, completion: { (result, message) in
                self.stopLoader()
                if(result == "Success"){
                    self.gotoConfirmation()
                }else{
                    DispatchQueue.main.async {
                        self.lblStatus.isHidden = false
                        self.lblStatus.text = message
                    }
                }
            })
        }else{
            DispatchQueue.main.async {
                self.lblStatus.isHidden = false
                self.lblStatus.text = "Please Check Your Internet"
            }
        }
    }

    func gotoConfirmation(){
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2SignUpConfirmation")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    @IBAction func resendTapped(){
        self.lblStatus.isHidden = true

        let email = UserDefaults.standard.string(forKey: "userEmail")
        let pass = UserDefaults.standard.string(forKey: "password")

        if(APIManager.shared.checkInternetAvailable()){
            startLoader()
            APIManager.shared.callResendApi(username: email!, password: pass!, completion: { (result, message) in
                self.stopLoader()
                if(result == "Success"){
                    self.lblStatus.text = message
                    self.lblStatus.isHidden = false
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if (string.count == 1){
            if textField == otpText1 {
                otpText2?.becomeFirstResponder()
            }
            if textField == otpText2 {
                otpText3?.becomeFirstResponder()
            }
            if textField == otpText3 {
                otpText4?.becomeFirstResponder()
            }
            if textField == otpText4 {
                otpText4?.resignFirstResponder()
            }
            textField.text? = string
            return false
        }else{
            if textField == otpText1 {
                otpText1?.becomeFirstResponder()
            }
            if textField == otpText2 {
                otpText1?.becomeFirstResponder()
            }
            if textField == otpText3 {
                otpText2?.becomeFirstResponder()
            }
            if textField == otpText4 {
                otpText3?.becomeFirstResponder()
            }
            textField.text? = string
            return false
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == self.otpText1){
            self.otpText1.resignFirstResponder()
            self.otpText2.becomeFirstResponder()
        }else if(textField == self.otpText2){
            self.otpText2.resignFirstResponder()
            self.otpText3.becomeFirstResponder()
        }else if(textField == self.otpText3){
            self.otpText3.resignFirstResponder()
            self.otpText4.becomeFirstResponder()
        }else if(textField == self.otpText4){
            self.otpText4.resignFirstResponder()
            self.submitTapped()
        }
        return true
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
