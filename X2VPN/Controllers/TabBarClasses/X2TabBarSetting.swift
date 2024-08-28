// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.


import Foundation
import UIKit
import NetworkExtension
import OneSignal


class X2TabBarSetting: UIViewController {
var protocolTpd: Bool = false

@IBOutlet weak var protocolView: UIView!
@IBOutlet weak var lblProtocol: UILabel!
@IBOutlet weak var imgProtocolArrow: UIImageView!
@IBOutlet weak var heightConstant: NSLayoutConstraint!
@IBOutlet weak var imgWireguard: UIImageView!
@IBOutlet weak var imgOpenVPN: UIImageView!
@IBOutlet weak var lblKillSwitchStat: UILabel!
@IBOutlet weak var imgKillSwitch: UIImageView!
@IBOutlet weak var lblNotifySwitchStat: UILabel!
@IBOutlet weak var imgNotifySwitch: UIImageView!

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    heightConstant.constant = 0
    protocolView.isHidden = true
}

override func viewDidLoad() {
    super.viewDidLoad()

    updateProtocolView()
    updateKillSwitch()
    updateNotification()
    NotificationCenter.default.post(name: Notification.Name("UpdateProtocol"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateProtocolView), name: NSNotification.Name("UpdateProtocol"), object: nil)
}

@IBAction func protocolTapped() {
    if protocolTpd {
        protocolTpd = false
    } else {
        protocolTpd = true
    }

    updateProtocolView()
}

@IBAction func wireguardTapped() {
    UserDefaults.standard.set(5, forKey: "selectedProtocol")
    updateProtocolView()

    NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
}

@IBAction func openVPNTapped() {
    UserDefaults.standard.set(1, forKey: "selectedProtocol")
    updateProtocolView()

    NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
}

@objc func updateProtocolView() {

    if protocolTpd {
        imgProtocolArrow.image = UIImage(named: "x2ArrowUpBlack")
        heightConstant.constant = 60
        protocolView.isHidden = false
    } else {
        imgProtocolArrow.image = UIImage(named: "x2ArrowDownBlack")
        heightConstant.constant = 0
        protocolView.isHidden = true
    }

    let selectedProtocol: Int = UserDefaults.standard.value(forKey: "selectedProtocol") as? Int ?? 5

    if (selectedProtocol == 5) {
        imgWireguard.image = UIImage(named: "x2Selected")
        imgOpenVPN.image = UIImage(named: "x2SelectedN")
        lblProtocol.text = "Wireguard"
    } else {
        imgWireguard.image = UIImage(named: "x2SelectedN")
        imgOpenVPN.image = UIImage(named: "x2Selected")
        lblProtocol.text = "OpenVPN"
    }
}

@IBAction func killSwitchTapped() {
    let killSwitchStat = UserDefaults.standard.bool(forKey: "killSwitchStat")

    if killSwitchStat {
        UserDefaults.standard.set(false, forKey: "killSwitchStat")
    } else {
        UserDefaults.standard.set(true, forKey: "killSwitchStat")
    }

    let isKillSwitchEnabled = UserDefaults.standard.bool(forKey: "IsKillSwitchEnabled")
    if(isKillSwitchEnabled){
        UserDefaults.standard.set(false, forKey: "IsKillSwitchEnabled")
    }else{
        UserDefaults.standard.set(true, forKey: "IsKillSwitchEnabled")
        // Update If VPN Is Connected

        // Load Managers For Enterprise VPN
        var vpnManagerEnterprise = NETunnelProviderManager()
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: { newManagers, error in
            if let error = error {
                print("Load Enterprise Preferences error: \(error)")
            } else {
                if newManagers!.count > 0 {
                    vpnManagerEnterprise = newManagers![0]
                    if(vpnManagerEnterprise.isEnabled){
                        let connection = vpnManagerEnterprise.connection
                        if(connection.status == .connected){
                            let rule = NEOnDemandRuleConnect()
                            rule.interfaceTypeMatch = .any
                            let onDemandRules = [rule]
                            vpnManagerEnterprise.onDemandRules = onDemandRules
                            vpnManagerEnterprise.isOnDemandEnabled = true

                            // Save To Preferences
                            vpnManagerEnterprise.saveToPreferences(completionHandler: {error in
                                if let error = error {
                                    print("Enterprise Save Config Failed: \(error.localizedDescription)")
                                }else{
                                    print("Enterprise Save Config Success")
                                }
                            })
                        }
                    }
                }
            }
        })
    }

    updateKillSwitch()
}

func updateKillSwitch() {
    let killSwitchStat = UserDefaults.standard.bool(forKey: "killSwitchStat")

    if killSwitchStat {
        imgKillSwitch.image = UIImage(named: "x2TgOn")
        lblKillSwitchStat.text = "On"
    } else {
        imgKillSwitch.image = UIImage(named: "x2TgOff")
        lblKillSwitchStat.text = "Off"
    }
}

@IBAction func notifyTapped() {
    let IsNotificationEnabled = UserDefaults.standard.bool(forKey: "IsNotificationEnabled")

    if IsNotificationEnabled {
        UserDefaults.standard.set(false, forKey: "IsNotificationEnabled")
    } else {
        UserDefaults.standard.set(true, forKey: "IsNotificationEnabled")
    }
    updateNotification()
}

func updateNotification() {
    if (UserDefaults.standard.bool(forKey: "IsNotificationEnabled")) {
        OneSignal.disablePush(false)
        imgNotifySwitch.image = UIImage(named: "x2TgOn")
        lblNotifySwitchStat.text = "On"
    }else{
        OneSignal.disablePush(true)
        imgNotifySwitch.image = UIImage(named: "x2TgOff")
        lblNotifySwitchStat.text = "Off"
    }
}
}
