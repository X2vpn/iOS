import UIKit

class CityCell: UITableViewCell {


    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var imgFlash: UIImageView!
    @IBOutlet weak var imgPing: UIImageView!
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblPing: UILabel!
    @IBOutlet weak var btnFav: UIButton!


    // Actions
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
