// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit


class X2Device: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tvDevice: UITableView!
    @IBOutlet weak var lblDeviceCount: UILabel!
    @IBOutlet weak var lblTotalDeviceCount: UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!

    private var deviceArray = [Device]()

    override func viewDidLoad() {
        super.viewDidLoad()


        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }

        // Set up table view
        tvDevice.delegate = self
        tvDevice.dataSource = self

        callGetDeviceList()
    }

    func callGetDeviceList(){

        if APIManager.shared.checkInternetAvailable() {
            startLoader()
            APIManager.shared.getDeviceList(completion: { [self] (result, list) in
                self.stopLoader()
                if result == "Success" {
                    deviceArray = list
                    print("result device: ", list.count)

                    let oldCount = UserDefaults.standard.integer(forKey: "deviceCount")
                    if list.count != oldCount {
                        NotificationCenter.default.post(name: Notification.Name("updateDevice"), object: nil)
                    }
                    tvDevice.reloadData()
                } else {
                    showToast(message: "Failed to load device")
                    deviceArray = list
                    tvDevice.reloadData()
                }
            })
        } else {
            print("No internet connection")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (deviceArray.count == 0){
            tableHeight.constant = 0
            return 0
        } else {
            tableHeight.constant = CGFloat(94 * deviceArray.count)
            lblDeviceCount.text = deviceArray.count.description
            return deviceArray.count
        }
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return deviceArray.count
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellForDevice", for: indexPath) as! CellForDevice
        let device = deviceArray[indexPath.row]

        cell.lblAppVersion.text = "\("App Version: ") \(device.appVersion ?? "1.0.0")"
        cell.lblDeviceModel.text = "\(device.brand ?? "Unknown") \(device.model ?? "Unknown")"
        cell.lblDeviceOs.text = "\(device.osName ?? "Unknown") \(device.osVersion ?? "Unknown")"
        cell.rootView.layer.cornerRadius = 10
        cell.rootView.layer.borderWidth = 1
        cell.rootView.layer.borderColor = UIColor(named: "E6E0E9")?.cgColor

        return cell
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
