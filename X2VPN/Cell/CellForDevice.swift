// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import UIKit

class CellForDevice: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var lblDeviceOs: UILabel!
    @IBOutlet weak var lblDeviceModel: UILabel!
    @IBOutlet weak var lblAppVersion: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
