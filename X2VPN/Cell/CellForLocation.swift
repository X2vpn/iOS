import UIKit

class CellForLocation: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!

    var serverTapped: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func selectTapped(sender: UIButton) {
        serverTapped?()
    }

}
