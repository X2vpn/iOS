// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2Feedback: UIViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var viewBad: UIView!
    @IBOutlet weak var viewAverage: UIView!
    @IBOutlet weak var viewGood: UIView!
    @IBOutlet weak var viewFeedback: UIView!
    @IBOutlet weak var tfFeedback: UITextField!

    @IBOutlet weak var lblSad: UILabel!//x2NeutralS
    @IBOutlet weak var lblHappy: UILabel!
    @IBOutlet weak var lblNeutral: UILabel!
    @IBOutlet weak var imgSad: UIImageView!
    @IBOutlet weak var imgHappy: UIImageView!
    @IBOutlet weak var imgNeutral: UIImageView!

    @IBOutlet weak var loader:UIActivityIndicatorView!

    private var emoji = ""
    private var tagArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        callFeedbackApi()

        print("emoji value: ", emoji)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        viewBad.layer.cornerRadius = 10
        viewGood.layer.cornerRadius = 10
        viewAverage.layer.cornerRadius = 10
        viewFeedback.layer.cornerRadius = 10
        btnSubmit.layer.cornerRadius = 10
    }

    func callFeedbackApi(){
        // Get Feedback Info From Server
        if(!APIManager.shared.checkInternetAvailable()){
            self.showToast(message: "Please Check Your Internet")
            return
        }

        self.startLoader()
        APIManager.shared.getFeedbackInfo(completion: {(result, info) in
            self.stopLoader()
            if(result == "Success"){
                self.parseFeedbackData(data: info!)
            }else{
                self.showToast(message: result)
            }
            self.updateUI()
        })
    }

    func parseFeedbackData(data: FeedbackResponse){

        // Emoji
        emoji = ""
        if(data.feedbackEmoji.happy == 1){
            emoji = "happy"
        }
        if(data.feedbackEmoji.sad == 1){
            emoji = "sad"
        }
        if(data.feedbackEmoji.expressionless == 1){
            emoji = "expressionless"
        }
    }

    func updateUI() {
        if (emoji == "happy") {
            lblSad.textColor = UIColor(named: "D03C1E")
            lblHappy.textColor = UIColor(named: "FFFFFF")
            lblNeutral.textColor = UIColor(named: "34B41F")
            imgSad.image = UIImage(named: "x2Sad")
            imgHappy.image = UIImage(named: "x2HappyS")
            imgNeutral.image = UIImage(named: "x2Neutral")
            viewBad.backgroundColor = UIColor(named: "FFF1F1")
            viewGood.backgroundColor = UIColor(named: "4758FF")
            viewAverage.backgroundColor = UIColor(named: "EAFBED")
        } else if (emoji == "sad") {
            lblSad.textColor = UIColor(named: "FFFFFF")
            lblHappy.textColor = UIColor(named: "4758FF")
            lblNeutral.textColor = UIColor(named: "34B41F")
            imgSad.image = UIImage(named: "x2SadS")
            imgHappy.image = UIImage(named: "x2Happy")
            imgNeutral.image = UIImage(named: "x2Neutral")
            viewBad.backgroundColor = UIColor(named: "D03C1E")
            viewGood.backgroundColor = UIColor(named: "EDEFFF")
            viewAverage.backgroundColor = UIColor(named: "EAFBED")
        } else if (emoji == "expressionless") {
            lblSad.textColor = UIColor(named: "D03C1E")
            lblHappy.textColor = UIColor(named: "4758FF")
            lblNeutral.textColor = UIColor(named: "FFFFFF")
            imgSad.image = UIImage(named: "x2Sad")
            imgHappy.image = UIImage(named: "x2Happy")
            imgNeutral.image = UIImage(named: "x2NeutralS")
            viewBad.backgroundColor = UIColor(named: "FFF1F1")
            viewGood.backgroundColor = UIColor(named: "EDEFFF")
            viewAverage.backgroundColor = UIColor(named: "34B41F")
        } else {
            lblSad.textColor = UIColor(named: "D03C1E")
            lblHappy.textColor = UIColor(named: "4758FF")
            lblNeutral.textColor = UIColor(named: "34B41F")
            imgSad.image = UIImage(named: "x2Sad")
            imgHappy.image = UIImage(named: "x2Happy")
            imgNeutral.image = UIImage(named: "x2Neutral")
            viewBad.backgroundColor = UIColor(named: "FFF1F1")
            viewGood.backgroundColor = UIColor(named: "EDEFFF")
            viewAverage.backgroundColor = UIColor(named: "EAFBED")
        }
    }


    @IBAction func submitTapped() {
        view.endEditing(true)

        if emoji == "" {
            showToast(message: " Please, select emoji.")
            return
        }

        if tfFeedback.text?.count == 0 {
            showToast(message: " Please, write your message.")
            return
        }

        if(!APIManager.shared.checkInternetAvailable()){
            self.showToast(message: "Please Check Your Internet")
            return
        }

        tagArray = [""]

        self.stopLoader()
        APIManager.shared.callFeedbackSubmitAPI(keywords: tagArray, emoji: emoji, feedback: tfFeedback.text ?? "", completion: {result in
            self.stopLoader()
            if (self.tagArray.count != 0) && (self.emoji != "") && (self.tfFeedback.text?.count != 0){
                self.showToast(message: result)
            }else{
                self.showToast(message: "Please, select emoji and write your message to submit feedback.")
            }
        })
    }

    @IBAction func emoHappyTapped(){
        if(emoji == "happy"){
            emoji = ""
        }else{
            emoji = "happy"
        }
        updateUI()
    }

    @IBAction func emoSadTapped(){
        if(emoji == "sad"){
            emoji = ""
        }else{
            emoji = "sad"
        }
        updateUI()
    }

    @IBAction func emoAverageTapped(){
        if(emoji == "expressionless"){
            emoji = ""
        }else{
            emoji = "expressionless"
        }
        updateUI()
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
}
