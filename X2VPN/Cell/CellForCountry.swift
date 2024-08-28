import UIKit

class CellForCountry: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var btnFav: UIButton!

    var favTapped: (() -> Void)? = nil
    var serverTapped: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func selectTapped(sender: UIButton) {
        serverTapped?()
    }

    @IBAction func favoriteTapped(sender: UIButton) {
        favTapped?()
    }

}
