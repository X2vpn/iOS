// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import UIKit

class X2Splash: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        gotoNextView()
    }

    func gotoNextView() {
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")

        if loggedIn {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "X2TabBar")
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false, completion: nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "X2Slide")
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false, completion: nil)
            }
        }
    }


}
