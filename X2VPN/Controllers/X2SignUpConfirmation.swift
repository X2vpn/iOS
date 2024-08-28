// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2SignUpConfirmation: UIViewController {

    @IBOutlet weak var btnDone: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnDone.layer.cornerRadius = 10
    }

    @IBAction func doneTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Login")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }

}
