// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2Slide: UIViewController {

    @IBOutlet var imgSlide: UIImageView!

    var pageContent = 1
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpTapped))
//        swipeUp.direction = .up
//        self.view.addGestureRecognizer(swipeUp)
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownTapped))
//        swipeDown.direction = .down
//        self.view.addGestureRecognizer(swipeDown)

        // Start the timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increasePageContent), userInfo: nil, repeats: true)
        updateUI()
    }

//    @objc func swipeUpTapped() {
//        if pageContent > 1 {
//            pageContent -= 1
//            updateUI()
//        }
//    }
//
//    @objc func swipeDownTapped() {
//        if pageContent < 3 {
//            pageContent += 1
//            updateUI()
//        } else {
//            gotoNext()
//        }
//    }

    @objc func increasePageContent() {
        if pageContent < 3 {
            pageContent += 1
            updateUI()
        } else {
            // Invalidate the timer when the pageContent reaches 3
            timer?.invalidate()
            timer = nil
            gotoNext()
        }
    }

    @objc func updateUI() {
        switch pageContent {
        case 1:
            imgSlide.image = UIImage(named: "x2Slide1")
        case 2:
            imgSlide.image = UIImage(named: "x2Slide2")
        case 3:
            imgSlide.image = UIImage(named: "x2Slide3")
        default:
            break
        }
    }


    func gotoNext() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Login")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

    deinit {
        timer?.invalidate()
    }

}
