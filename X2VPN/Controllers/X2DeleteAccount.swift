
import Foundation
import UIKit
import UICKeyChainStore
import NetworkExtension

class X2DeleteAccount: UIViewController {

    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var btnSure: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblStatus.isHidden = true
        loader.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        btnSure.layer.cornerRadius = 10
        passView.layer.cornerRadius = 10
    }

    @IBAction func backTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

    @IBAction func sureTapped() {
        view.endEditing(true)
        lblStatus.isHidden = true

        let keychain = UICKeyChainStore(service: "X2VPN")
        let password = keychain.string(forKey: "password")

        let passwordText = tfPassword.text ?? ""

        if(password != passwordText){
            lblStatus.text = "Password doesn't match"
            lblStatus.isHidden = false
            return
        }
        startLoader()
        APIManager.shared.callDeleteAccountAPI(completion: { [self]response in
            self.stopLoader()
            if(response == "Success"){
                self.goToLoginPage()
            }else{
                lblStatus.text = response
                lblStatus.isHidden = false
            }
        })
    }

    func goToLoginPage(){
        if(UserDefaults.standard.string(forKey: "VPNStatus") == "Connected" || UserDefaults.standard.string(forKey: "VPNStatus") == "Connecting"){
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
                                if(vpnManagerEnterprise.isOnDemandEnabled){
                                    vpnManagerEnterprise.isOnDemandEnabled = false
                                    vpnManagerEnterprise.saveToPreferences(completionHandler: {error in
                                        if let error = error {
                                            print("Enterprise Save to Preferences Error: \(error)")
                                        } else {
                                            print("Save successfully")
                                            vpnManagerEnterprise.connection.stopVPNTunnel()
                                        }
                                        JHNetworkSpeed.share().stop()
                                        self.proceedToLogout()
                                    })
                                }else{
                                    vpnManagerEnterprise.connection.stopVPNTunnel()
                                    JHNetworkSpeed.share().stop()
                                    self.proceedToLogout()
                                }
                            }
                        }
                    }
                }
            })
        }else{
            proceedToLogout()
        }
    }

    func proceedToLogout(){
        UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
        UserDefaults.standard.set(false, forKey: "IsLoggedIn")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "X2Login")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
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
