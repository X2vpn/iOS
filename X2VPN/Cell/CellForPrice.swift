// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class CellForPrice: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var lblTitle: UILabel!

    var priceTapped: (() -> Void)? = nil

    @IBAction func priceSelected(sender: UIButton) {
        priceTapped?()
    }

}
