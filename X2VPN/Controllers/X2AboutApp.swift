// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class X2AboutApp: UIViewController {

    @IBOutlet weak var btnView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnView.layer.cornerRadius = 10
    }

    @IBAction func backTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

    @IBAction func updateTapped() {
        showToast(message: "Update Tapped")
    }
}
