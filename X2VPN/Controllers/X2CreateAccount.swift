// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2CreateAccount: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblCustom: UILabel!
    @IBOutlet weak var btnAgree: UIButton!

    private var isAgreed = false


    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblStatus.isHidden = true

        // Your original string
        let fullString = "By creating an account, i accept all terms of service and privacy policy"

        // Create an attributed string
        let attributedString = NSMutableAttributedString(string: fullString)

        // Find the ranges of the substrings you want to customize using regular expressions
        if let range1 = fullString.range(of: "terms of service", options: .regularExpression),
           let range2 = fullString.range(of: "privacy policy", options: .regularExpression) {

            // Set the attributes for the first substring
            attributedString.addAttribute(.foregroundColor, value: UIColor(named: "4758FF")!, range: NSRange(range1, in: fullString))
//            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(range1, in: fullString))

            // Set the attributes for the second substring
            attributedString.addAttribute(.foregroundColor, value: UIColor(named: "4758FF")!, range: NSRange(range2, in: fullString))
//            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(range2, in: fullString))
        }

        // Apply the attributed string to your label
        lblCustom.attributedText = attributedString

        // Enable user interaction on the label
        lblCustom.isUserInteractionEnabled = true

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        lblCustom.addGestureRecognizer(tapGesture)

        updateAgreeCheckBoxUI()
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = lblCustom.attributedText else { return }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let locationOfTouchInLabel = gesture.location(in: lblCustom)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInLabel, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if let termsRange = lblCustom.text?.range(of: "terms of service"),
           let privacyRange = lblCustom.text?.range(of: "privacy policy") {

            if NSRange(termsRange, in: lblCustom.text!).contains(indexOfCharacter) {
                guard let url = URL(string: "http://194.233.71.193:1221/terms_service/") else {
                  return //be safe
                }

                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else if NSRange(privacyRange, in: lblCustom.text!).contains(indexOfCharacter) {
                guard let url = URL(string: "http://194.233.71.193:1221/privacy_policy/") else {
                  return //be safe
                }

                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        btnCreate.layer.cornerRadius = 10
        emailView.layer.cornerRadius = 10
    }

    @IBAction func agreeTapped() {
        if(isAgreed){
            isAgreed = false
        }else{
            isAgreed = true
        }
        updateAgreeCheckBoxUI()
    }

    func updateAgreeCheckBoxUI(){
        if(isAgreed){
            btnAgree.setImage(UIImage(named: "x2RadioChecked"), for: .normal)
        }else{
            btnAgree.setImage(UIImage(named: "x2RadioUnchecked"), for: .normal)
        }
    }

    @IBAction func backTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

    @IBAction func createTapped() {
        self.lblStatus.isHidden = true

        let email = tfEmail.text ?? ""

        if(!isValidEmail(email)){
            self.lblStatus.isHidden = false
            self.lblStatus.text = "Email address invalid"
            return
        }else if(!isAgreed){
            self.lblStatus.isHidden = false
            self.lblStatus.text = "Please check terms & condition to proceed"
            return
        } else {
            UserDefaults.standard.setValue(email, forKey: "userEmail")
            gotoNextView()
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

    func gotoNextView() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2UserDetails")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

}
