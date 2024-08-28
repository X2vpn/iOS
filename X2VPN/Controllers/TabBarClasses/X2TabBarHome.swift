// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit
import NetworkExtension
import UICKeyChainStore
import Lottie


class X2TabBarHome: UIViewController {
    var appDelegate: AppDelegate!
    @IBOutlet var lottieView:LottieAnimationView!

    @IBOutlet weak var imgCircle: UIImageView!
    @IBOutlet weak var imgStat: UIImageView!
    @IBOutlet weak var imgArrow: UIImageView!

    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var lblPopStatus: UILabel!
    @IBOutlet weak var lblProtocol: UILabel!
    @IBOutlet weak var lblProtectedIp: UILabel!
    @IBOutlet weak var lblDataEnc: UILabel!
    @IBOutlet weak var lblDownload: UILabel!
    @IBOutlet weak var lblUpload: UILabel!
    @IBOutlet weak var lblProtocolName: UILabel!
    @IBOutlet weak var lblIP: UILabel!
    @IBOutlet weak var lblDataEncState: UILabel!
    @IBOutlet weak var lblDownloadSpeed: UILabel!
    @IBOutlet weak var lblUploadSpeed: UILabel!
    @IBOutlet weak var pop1: UIView!
    @IBOutlet weak var pop2: UIView!
    @IBOutlet weak var pop3: UIView!
    @IBOutlet weak var pop4: UIView!
    @IBOutlet weak var pop5: UIView!


    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var connectView: UIView!
    @IBOutlet weak var lblConnect: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var viewRecent: UIView!
    @IBOutlet weak var viewServer: UIView!

    @IBOutlet weak var viewRecent1:UIView!
    @IBOutlet weak var viewRecent2:UIView!
    @IBOutlet weak var viewRecent3:UIView!
    @IBOutlet weak var viewRecent4:UIView!
    @IBOutlet weak var viewRecent5:UIView!
    @IBOutlet weak var lblRecentCountry1:UILabel!
    @IBOutlet weak var lblRecentCountry2:UILabel!
    @IBOutlet weak var lblRecentCountry3:UILabel!
    @IBOutlet weak var lblRecentCountry4:UILabel!
    @IBOutlet weak var lblRecentCountry5:UILabel!
    @IBOutlet weak var lblRecentCity1:UILabel!
    @IBOutlet weak var lblRecentCity2:UILabel!
    @IBOutlet weak var lblRecentCity3:UILabel!
    @IBOutlet weak var lblRecentCity4:UILabel!
    @IBOutlet weak var lblRecentCity5:UILabel!
    @IBOutlet weak var imgRecentCountry1:UIImageView!
    @IBOutlet weak var imgRecentCountry2:UIImageView!
    @IBOutlet weak var imgRecentCountry3:UIImageView!
    @IBOutlet weak var imgRecentCountry4:UIImageView!
    @IBOutlet weak var imgRecentCountry5:UIImageView!

    private var recentServerArray = [Int]()

    private var startVPNFromServer: Bool = false
    private var vpnManagerEnterprise = NETunnelProviderManager()
    private var selectedServer: IPBundle!
    private var allServer = [IPBundle]()
    private var currentServerStatus:NEVPNStatus = .disconnected
    private var speed = JHNetworkSpeed.share()

    var cityProtocol:Int = 0
    var popTapped: Bool = false
    var localIPFetched: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popView.isHidden = true
        lottieView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Reference to the AppDelegate
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate = delegate
        } else {
            print("Failed to get AppDelegate reference")
        }

        parseServerData()
        checkVPNStatus()
        initializePage()
        updateUIOnMainThread()
        updateRecentServer()

        let isKillSwitchEnabled = UserDefaults.standard.bool(forKey: "IsKillSwitchEnabled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            if isKillSwitchEnabled{
                connectTapped(nil)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.onVPNStatusChanged), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connect), name: NSNotification.Name("ConnectVPN"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelected), name: NSNotification.Name("updateServer"), object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        viewStatus.layer.cornerRadius = self.viewStatus.frame.height/2
        viewServer.layer.cornerRadius = 20
        connectView.layer.cornerRadius = 10
        connectView.layer.borderWidth = 1

        imgRecentCountry1.layer.cornerRadius = 4
        imgRecentCountry2.layer.cornerRadius = 4
        imgRecentCountry3.layer.cornerRadius = 4
        imgRecentCountry4.layer.cornerRadius = 4
        imgRecentCountry5.layer.cornerRadius = 4
        imgCountry.layer.cornerRadius = 6
        popView.layer.cornerRadius = 28

        pop1.layer.cornerRadius = 11
        pop2.layer.cornerRadius = 11
        pop3.layer.cornerRadius = 11
        pop4.layer.cornerRadius = 11
        pop5.layer.cornerRadius = 11
    }

    @objc func connect() {
        parseServerData()
        updateServerUI()
        connectTapped(nil)
    }

    @objc func updateSelected() {
        let status = UserDefaults.standard.string(forKey: "VPNStatus")
        if status != "Connected" {
            parseServerData()
            updateServerUI()
        }
    }

    func updateRecentServer(){
//        let delegate = UIApplication.shared.delegate as? AppDelegate

        let recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()
        print("get recent server: \(recentArray.count)")

        if(recentArray.count == 5){
            viewRecent1.isHidden = false
            viewRecent2.isHidden = false
            viewRecent3.isHidden = false
            viewRecent4.isHidden = false
            viewRecent5.isHidden = false

            let city1 = appDelegate.getCityByID(cityID: recentArray[0])
            lblRecentCountry1.text = city1?.countryName
            lblRecentCity1.text = city1?.ipName
            imgRecentCountry1.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city1?.countryCode)!) ?? "")!

            let city2 = appDelegate.getCityByID(cityID: recentArray[1])
            lblRecentCountry2.text = city2?.countryName
            lblRecentCity2.text = city2?.ipName
            imgRecentCountry2.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city2?.countryCode)!) ?? "")!

            let city3 = appDelegate.getCityByID(cityID: recentArray[2])
            lblRecentCountry3.text = city3?.countryName
            lblRecentCity3.text = city3?.ipName
            imgRecentCountry3.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city3?.countryCode)!) ?? "")!

            let city4 = appDelegate.getCityByID(cityID: recentArray[3])
            lblRecentCountry4.text = city4?.countryName
            lblRecentCity4.text = city4?.ipName
            imgRecentCountry4.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city4?.countryCode)!) ?? "")!

            let city5 = appDelegate.getCityByID(cityID: recentArray[4])
            lblRecentCountry5.text = city5?.countryName
            lblRecentCity5.text = city5?.ipName
            imgRecentCountry5.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city5?.countryCode)!) ?? "")!

        }else if(recentArray.count == 4){
            viewRecent1.isHidden = false
            viewRecent2.isHidden = false
            viewRecent3.isHidden = false
            viewRecent4.isHidden = false
            viewRecent5.isHidden = true

            let city1 = appDelegate.getCityByID(cityID: recentArray[0])
            lblRecentCountry1.text = city1?.countryName
            lblRecentCity1.text = city1?.ipName
            imgRecentCountry1.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city1?.countryCode)!) ?? "")!

            let city2 = appDelegate.getCityByID(cityID: recentArray[1])
            lblRecentCountry2.text = city2?.countryName
            lblRecentCity2.text = city2?.ipName
            imgRecentCountry2.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city2?.countryCode)!) ?? "")!

            let city3 = appDelegate.getCityByID(cityID: recentArray[2])
            lblRecentCountry3.text = city3?.countryName
            lblRecentCity3.text = city3?.ipName
            imgRecentCountry3.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city3?.countryCode)!) ?? "")!

            let city4 = appDelegate.getCityByID(cityID: recentArray[3])
            lblRecentCountry4.text = city4?.countryName
            lblRecentCity4.text = city4?.ipName
            imgRecentCountry4.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city4?.countryCode)!) ?? "")!

        }else if(recentArray.count == 3){
            viewRecent1.isHidden = false
            viewRecent2.isHidden = false
            viewRecent3.isHidden = false
            viewRecent4.isHidden = true
            viewRecent5.isHidden = true

            let city1 = appDelegate.getCityByID(cityID: recentArray[0])
            lblRecentCountry1.text = city1?.countryName
            lblRecentCity1.text = city1?.ipName
            imgRecentCountry1.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city1?.countryCode)!) ?? "")!

            let city2 = appDelegate.getCityByID(cityID: recentArray[1])
            lblRecentCountry2.text = city2?.countryName
            lblRecentCity2.text = city2?.ipName
            imgRecentCountry2.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city2?.countryCode)!) ?? "")!

            let city3 = appDelegate.getCityByID(cityID: recentArray[2])
            lblRecentCountry3.text = city3?.countryName
            lblRecentCity3.text = city3?.ipName
            imgRecentCountry3.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city3?.countryCode)!) ?? "")!

        }else if(recentArray.count == 2){
            viewRecent1.isHidden = false
            viewRecent2.isHidden = false
            viewRecent3.isHidden = true
            viewRecent4.isHidden = true
            viewRecent5.isHidden = true

            let city1 = appDelegate.getCityByID(cityID: recentArray[0])
            lblRecentCountry1.text = city1?.countryName
            lblRecentCity1.text = city1?.ipName
            imgRecentCountry1.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city1?.countryCode)!) ?? "")!

            let city2 = appDelegate.getCityByID(cityID: recentArray[1])
            lblRecentCountry2.text = city2?.countryName
            lblRecentCity2.text = city2?.ipName
            imgRecentCountry2.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city2?.countryCode)!) ?? "")!

        }else if(recentArray.count == 1){
            viewRecent1.isHidden = false
            viewRecent2.isHidden = true
            viewRecent3.isHidden = true
            viewRecent4.isHidden = true
            viewRecent5.isHidden = true

            let city1 = appDelegate.getCityByID(cityID: recentArray[0])
            lblRecentCountry1.text = city1?.countryName
            lblRecentCity1.text = city1?.ipName
            imgRecentCountry1.image = UIImage(named: appDelegate?.getFlagImage(countryCode: (city1?.countryCode)!) ?? "")!

        }else{
            viewRecent1.isHidden = true
            viewRecent2.isHidden = true
            viewRecent3.isHidden = true
            viewRecent4.isHidden = true
            viewRecent5.isHidden = true
//            viewRecent.isHidden = true
        }
    }



    @objc func parseServerData(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()
        for server in serverList{

            if((server.platform == "all" || server.platform == "ios") && isProtocolEnabled(type: server.type!)) {
                allServer.append(server)
            }
        }

        if(allServer.count > 0){
            selectedServer = getSelectedServer()
        }else{
            selectedServer = nil
        }
    }

    func isProtocolEnabled(type:Int) -> Bool{
        let protocolType: Int = UserDefaults.standard.value(forKey: "selectedProtocol") as? Int ?? 5
        UserDefaults.standard.set(protocolType, forKey: "selectedProtocol")
        if(type == 1 || type == 6){
//            UserDefaults.standard.set(1, forKey: "selectedProtocol")
            if(protocolType == 1){
                return true
            }
        }else{
            if(protocolType == type){
                return true
            }
        }
        return false
    }

    func getSelectedServer() -> IPBundle?{
        let selectedServerID = UserDefaults.standard.integer(forKey: "selectedServerID")

        print("get selected server id home: ", selectedServerID)

        var serverFound = false
        for server in allServer{
            if(server.ipID == selectedServerID){
                serverFound = true
                print("server found: ", serverFound)
                return server
            }
        }


        if(!serverFound){
            let findServer = self.findAnyServer()
            UserDefaults.standard.set(findServer?.ipID, forKey: "selectedServerID")
            print("server found: ", serverFound)
            UserDefaults.standard.synchronize()
            return findServer
        }
    }

    func findAnyServer() -> IPBundle?{
        for server in allServer{
            return server
        }
        return allServer.first
    }

    // User Defined Functions
    func initializePage(){
        // Get AppDelegate
        let delegate = UIApplication.shared.delegate as? AppDelegate
        vpnManagerEnterprise = NETunnelProviderManager()

        delegate?.startAutoLogoutTimer()
    }

    @objc func checkVPNStatus(){
        // Load Managers For Enterprise VPN
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: { [self] newManagers, error in
            if let error = error {
                print("Load Preferences error: \(error)")
            } else {
                if newManagers!.count > 0 {
                    self.vpnManagerEnterprise = newManagers![0]
                    if(self.vpnManagerEnterprise.isEnabled){
                        let connection = self.vpnManagerEnterprise.connection
                        self.currentServerStatus = connection.status
                        if(connection.status == .connected){
                            UserDefaults.standard.set("Connected", forKey: "VPNStatus")
                        }else{
                            UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
                        }
                        UserDefaults.standard.synchronize()
                        self.updateUIOnMainThread()
                    }
                }
            }
        })
    }

    @objc func updateUIOnMainThread(){

        DispatchQueue.main.async {
            self.updateUI()
        }
    }

    func updateServerUI(){
        // Get AppDelegate Refernce
        let delegate = UIApplication.shared.delegate as? AppDelegate

        selectedServer = getSelectedServer()

//        print("selected server on update serverUI: ", selectedServer)

        // Update Server UI
        if(selectedServer != nil){
            imgCountry.image = UIImage(named: (delegate?.getFlagImage(countryCode: selectedServer.countryCode!))!)
            let countryName = selectedServer.countryName
            let serverName = selectedServer.ipName
            lblCountry.text = countryName
            lblCity.text = serverName
        }
    }

    @objc func updateUI() {
        let status = self.vpnManagerEnterprise.connection.status
        print("VPN status update ui: \(status)")
        updateServerUI()

        if(status == .connected){
            print("UI updating for connected")
            lblConnect.text = "Disconnect VPN"
            lblConnect.textColor = UIColor(named: "4F03E0")
            connectView.backgroundColor = UIColor(named: "D6CEFF")
            connectView.layer.borderColor = UIColor(named: "4F03E0")?.cgColor

            lblStatus.text = "Protected Internet"
            lblStatus.textColor = UIColor(named: "34B41F")
            viewStatus.backgroundColor = UIColor(named: "EAFFE2")
            imgStat.image = UIImage(named: "x2Protected")
            imgCircle.image = UIImage(named: "x2CircleConnected")

            if popTapped {
                imgArrow.image = UIImage(named: "x2ArrowUpGreen")
            } else {
                imgArrow.image = UIImage(named: "x2ArrowDownGreen")
            }

            popView.backgroundColor = UIColor(named: "CCE9C2")
            lblPopStatus.text = "Protected Internet Status"

            lblProtocol.textColor = UIColor(named: "1D1B20")
            lblProtocolName.textColor = UIColor(named: "1D1B20")
            let selectedProtocol = UserDefaults.standard.integer(forKey: "selectedProtocol")

            if selectedProtocol == 5 {
                lblProtocolName.text = "Wireguard"
            } else {
                lblProtocolName.text = "Open VPN"
            }

            lblProtectedIp.textColor = UIColor(named: "000000")
            lblProtectedIp.text = "Protected IP"
//            lblIP.text = UserDefaults.standard.string(forKey: "serverIP")
            lblIP.textColor = UIColor(named: "000000")
            lblDataEnc.textColor = UIColor(named: "000000")
            lblDataEncState.text = "YES"
            lblDataEncState.textColor = UIColor(named: "000000")
            lblDownload.textColor = UIColor(named: "000000")
            lblUpload.textColor = UIColor(named: "000000")
            lblDownloadSpeed.textColor = UIColor(named: "000000")
            lblUploadSpeed.textColor = UIColor(named: "000000")

            DispatchQueue.main.async {
                self.speed!.speedBlock = ({(uploadSpeed, downloadSpeed, totalDownload, totalUpload) in
                        self.lblUploadSpeed.text = uploadSpeed
                        self.lblDownloadSpeed.text = downloadSpeed
                })
            }
            speed!.start()

            lottieView.isHidden = true

            getLocalIPAddress()

        }else if(status == .connecting){

            print("UI updating for connecting/disconnecting")
            lblConnect.text = "Connecting..."
            lblConnect.textColor = UIColor(named: "FFFFFF")
            connectView.backgroundColor = UIColor(named: "D6CEFF")
            connectView.layer.borderColor = UIColor .clear.cgColor

            lblStatus.text = "Unprotected Internet"
            lblStatus.textColor = UIColor(named: "FF8D00")
            viewStatus.backgroundColor = UIColor(named: "FFE9D6")
            imgStat.image = UIImage(named: "x2Unprotected")
            imgCircle.image = UIImage(named: "x2CircleConnecting")

            if popTapped {
                imgArrow.image = UIImage(named: "x2ArrowUpOrange")
            } else {
                imgArrow.image = UIImage(named: "x2ArrowDownOrange")
            }

            popView.backgroundColor = UIColor(named: "EFDAC6")
            lblPopStatus.text = "Unprotected Internet Status"

            lblProtocol.textColor = UIColor(named: "FF8D00")
            lblProtocolName.textColor = UIColor(named: "FF8D00")

            lblProtocolName.text = "--"

            lblProtectedIp.textColor = UIColor(named: "D03C1E")
            lblProtectedIp.text = "Unprotected IP"
//            lblIP.text = "..."
            lblIP.textColor = UIColor(named: "D03C1E")
            lblDataEnc.textColor = UIColor(named: "D03C1E")
            lblDataEncState.text = "NO"
            lblDataEncState.textColor = UIColor(named: "D03C1E")
            lblDownload.textColor = UIColor(named: "48464C")
            lblUpload.textColor = UIColor(named: "48464C")
            lblDownloadSpeed.textColor = UIColor(named: "48464C")
            lblUploadSpeed.textColor = UIColor(named: "48464C")

            lblUploadSpeed.text = "0.0 Bs"
            lblDownloadSpeed.text = "0.0 Bs"

            lottieView.isHidden = false
            lottieView.animation = .named("animation")
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            lottieView.play()
        }else if(status == .disconnected || status == .invalid){

            print("UI updating for disconnected")
            lblConnect.text = "Connect VPN"
            lblConnect.textColor = UIColor(named: "FFFFFF")
            connectView.backgroundColor = UIColor(named: "4F03E0")
            connectView.layer.borderColor = UIColor .clear.cgColor

            lblStatus.text = "Unprotected Internet"
            lblStatus.textColor = UIColor(named: "FF8D00")
            viewStatus.backgroundColor = UIColor(named: "FFE9D6")
            imgStat.image = UIImage(named: "x2Unprotected")
            imgCircle.image = UIImage(named: "x2CircleDisconnected")

            if popTapped {
                imgArrow.image = UIImage(named: "x2ArrowUpOrange")
            } else {
                imgArrow.image = UIImage(named: "x2ArrowDownOrange")
            }

            popView.backgroundColor = UIColor(named: "EFDAC6")
            lblPopStatus.text = "Unprotected Internet Status"

            lblProtocol.textColor = UIColor(named: "FF8D00")
            lblProtocolName.textColor = UIColor(named: "FF8D00")

            lblProtocolName.text = "--"

            lblProtectedIp.textColor = UIColor(named: "D03C1E")
            lblProtectedIp.text = "Unprotected IP"
//            lblIP.text = "..."
            lblIP.textColor = UIColor(named: "D03C1E")
            lblDataEnc.textColor = UIColor(named: "D03C1E")
            lblDataEncState.text = "NO"
            lblDataEncState.textColor = UIColor(named: "D03C1E")
            lblDownload.textColor = UIColor(named: "48464C")
            lblUpload.textColor = UIColor(named: "48464C")
            lblDownloadSpeed.textColor = UIColor(named: "48464C")
            lblUploadSpeed.textColor = UIColor(named: "48464C")

            speed!.stop()
            lblUploadSpeed.text = "0.0 Bs"
            lblDownloadSpeed.text = "0.0 Bs"

            lottieView.isHidden = true
            getLocalIPAddress()
            }

        NotificationCenter.default.post(name: Notification.Name("VPNStatusChanged"), object: nil)
    }

    func getLocalIPAddress() {
        if(!localIPFetched){
            localIPFetched = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.getLocalIP()
            }
        }
    }

    func getLocalIP(){
        print("Getting Local IP")
        let url = URL(string: "https://httpbin.org/ip")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            print("getLocalIPAddress: data: \(String(describing: data)), error: \(String(describing: error))")
            if let error = error {
                print("getLocalIPAddress: Error: \(error)")
                self.localIPFetched = false
                return
            }

            guard let data = data else {
                print("getLocalIPAddress: No data received.")
                self.localIPFetched = false
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let ip = json["origin"] as? String {
                    self.localIPFetched = false
                    print("Local IP => \(ip)")
                    DispatchQueue.main.async {
                        self.lblIP.text = ip
                    }
                } else {
                    print("Unable to parse JSON.")
                    self.localIPFetched = false
                }
            } catch {
                print("getLocalIPAddress: \(error)")
                self.localIPFetched = false
            }
        }

        task.resume()
    }


    @IBAction func connectTapped(_ sender: Any?) {
        let vpnStatus = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if(vpnStatus == "Connected" || vpnStatus == "Connecting"){
            stopVPN()
            updateUIOnMainThread()
        }else{
            let delegate = UIApplication.shared.delegate as? AppDelegate
            let userData = delegate?.getuserData()
            if(selectedServer != nil){
                if(userData?.userStatus == "3"){
                    self.showToast(message: "User Expired")
                }else{
                    startVPN()
                }
            }else{
                selectedServer = getSelectedServer()
                if(selectedServer != nil){
                    UserDefaults.standard.set(selectedServer?.ipID, forKey: "selectedServerID")
//                    UserDefaults.standard.set(selectedServer.ip, forKey: "serverIP")
                    if(userData?.userStatus == "3"){
                        self.showToast(message: "User Expired")
                    }else{
                        startVPN()
                    }
                }else{
                    self.showToast(message: "No Server Found. Please Contact Support")
                }
            }
        }
    }

    func startVPN(){
//        let keychain = UICKeyChainStore(service: "X2VPN")
        self.recentServerArray.append(selectedServer.ipID!)
//        UserDefaults.standard.set(self.recentServerArray, forKey: "recentServerLists\(keychain.string(forKey: "userEmail")!)")

//        print("selected server: ", selectedServer.ipID!, "recent server array: \(recentServerArray)")
//        UserDefaults.standard.setValue(true, forKey: "FirstConnect")


        self.appDelegate.addRecentServerData(cityID: "\(String(describing: selectedServer.ipID))")
        updateRecentServer()

        if(selectedServer.type == 5){
            //vpnLoader.startVPNLoader()
            APIManager.shared.getWGConfigOn(serverID: selectedServer.vpnServerID!, ipID: selectedServer.ipID!, completion: {config in
                self.startEnterpriseVPN(config: config)
            })
        }else{
            startEnterpriseVPN(config: selectedServer.config!)
        }




    }

    func startEnterpriseVPN(config:String){
        UserDefaults.standard.set("Enterprise", forKey: "VPNType")
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: {managers, error in
            if let error = error{
                print("Enterprise Load All Preferences error: \(error)")
            }else{
//                print("Enterprise Load All Preferences Done")
                if(managers!.count > 0){
                    print("Mangers Count : \(managers!.count)")
                    self.vpnManagerEnterprise = managers![0]
                }else{
                    //print("Initializing New Manager")
                    self.vpnManagerEnterprise = NETunnelProviderManager()
                }
                self.vpnManagerEnterprise.loadFromPreferences(completionHandler: { error in
                    if let error = error{
                        print("Enterprise Load Preferences error: \(error)")
                    } else {
//                        print("Enterprise Load Preferences Done")
                        let protocolConfig = self.vpnManagerEnterprise.protocolConfiguration as? NETunnelProviderProtocol ?? NETunnelProviderProtocol()

//                        print("Protocol config: ", protocolConfig)

                        if (self.selectedServer.type == 1 || self.selectedServer.type == 6) {
                            // Configuration For OpenVPN
                            protocolConfig.providerBundleIdentifier = "com.rivernet.x2vpnios.ConnectTunnel"
                            let defaults = UserDefaults.init(suiteName: "group.com.rivernet.x2vpnios")
                            defaults!.set("OpenVPN", forKey: "VPNCategory")

                            let config = self.selectedServer.config
                            let decodedData = Data(base64Encoded: config!, options: [])
                            var string: String? = nil
                            if let decodedData = decodedData {
                                string = String(data: decodedData, encoding: .utf8)
                            }

                            let data = string!.data(using: .utf8)
                            protocolConfig.providerConfiguration = ["ovpn": data!]
                            protocolConfig.serverAddress = self.selectedServer.ip
                        } else if(self.selectedServer.type == 5) {
                            // Configuration For WireGuard
                            protocolConfig.providerBundleIdentifier = "com.rivernet.x2vpnios.network-extension"
                            protocolConfig.serverAddress = self.selectedServer.ip
                        }

                        self.vpnManagerEnterprise.localizedDescription = "X2VPN"
                        self.vpnManagerEnterprise.protocolConfiguration = protocolConfig
                        self.vpnManagerEnterprise.isEnabled = true

//                        print("User Details: ", self.selectedServer.ip, config)

                        // Check If KillSwitch Is On
                        if(UserDefaults.standard.bool(forKey: "IsKillSwitchEnabled")){
                            let rule = NEOnDemandRuleConnect()
                            rule.interfaceTypeMatch = .any
                            let onDemandRules = [rule]
                            self.vpnManagerEnterprise.onDemandRules = onDemandRules
                            self.vpnManagerEnterprise.isOnDemandEnabled = true
                        }else{
                            self.vpnManagerEnterprise.isOnDemandEnabled = false
                        }

                        // Save Personal VPN Preferences
                        self.vpnManagerEnterprise.saveToPreferences(completionHandler: {error in
                            if let error = error {
                                print("Enterprise Save config failed: \(error.localizedDescription)")
                            }else{
                                //print("Enterprise Save config done")
                                UserDefaults.standard.set("Connecting", forKey: "VPNStatus")

                                if(self.selectedServer.type == 1 || self.selectedServer.type == 6){
                                    self.openTunnel()
                                }else if(self.selectedServer.type == 5){
                                    self.startWireguard(config: config)
                                }
                            }
                        })
                    }
                })
            }
        })
    }

    func openTunnel(){
        vpnManagerEnterprise.loadFromPreferences(completionHandler: { error in
            if let error = error{
                print("Enterprise Load Preferences error: \(error)")
            }else{
                //print("Enterprise Load Preferences For Start Done")
                UserDefaults.standard.set(Date(), forKey: "StartDate")
                if(self.selectedServer.type == 1  || self.selectedServer.type == 6){
                    // Start OpenVPN
                    print("Connecting Open VPN")
                    let keychain = UICKeyChainStore(service: "X2VPN")
                    do{
                        try self.vpnManagerEnterprise.connection.startVPNTunnel(options: [
                            "username": keychain.string(forKey: "userEmail")! as NSObject,
                            "password": keychain.string(forKey: "password")! as NSObject
                        ])
                    }catch let error as NSError {
                        print("OpenVPN Start Error: \(error.localizedDescription)")
                    }
                }
            }
        })
    }

    func startWireguard(config: String){
//        print("Connecting WireGuard")
        print(config)
        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("Error Creating Tunnel Manager: \(String(describing: error))")
            case .success(let tunnelsManager):
                var tunnelConfiguration: TunnelConfiguration?
                do{
                    tunnelConfiguration = try TunnelConfiguration(fromWgQuickConfig: config, called: "X2VPN")
                    if (tunnelsManager.numberOfTunnels() > 0) {
                        let tunnel = tunnelsManager.tunnel(at: 0)
                        // We're modifying an existing tunnel
                        tunnelsManager.modify(tunnel: tunnel, tunnelConfiguration: tunnelConfiguration!, onDemandOption: .off) { error in
                            if let error = error {
                                print("Error modifying tunnel: \(String(describing: error))")
                                return
                            } else {

                                tunnelsManager.startActivation(of: tunnel)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.onVPNStatusChanged()
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self.onVPNStatusChanged()
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    self.onVPNStatusChanged()
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                    self.onVPNStatusChanged()
                                }

                                self.checkVPNStatus()
                            }
                        }
                    } else {
                        // We're creating a new tunnel
                        tunnelsManager.add(tunnelConfiguration: tunnelConfiguration!, onDemandOption: .off) { result in
                            switch result {
                            case .failure(let error):
                                print("Error adding tunnel: \(String(describing: error))")
                            case .success(let tunnel):
                                UserDefaults.standard.set("Connected", forKey: "VPNStatus")
                                tunnelsManager.startActivation(of: tunnel)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.onVPNStatusChanged()
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self.onVPNStatusChanged()
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    self.onVPNStatusChanged()
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                    self.onVPNStatusChanged()
                                }
                            }
                        }
                    }
                } catch let error {
                    print("Error starting tunnel: \(String(describing: error))")
                }
            }
        }
    }



    func closeWGConnection(){
        APIManager.shared.getWGConfigOff(serverID: self.selectedServer.vpnServerID!, ipID: self.selectedServer.ipID!, completion: {response in
            print(response)
        })
    }

    @objc func stopVPN(){
        let isKillSwitchEnabled = UserDefaults.standard.bool(forKey: "IsKillSwitchEnabled")
        if(isKillSwitchEnabled){
            vpnManagerEnterprise.isOnDemandEnabled = true
            vpnManagerEnterprise.connection.stopVPNTunnel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
                self.updateUIOnMainThread()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.connectTapped(nil)
            }

        }else{
            vpnManagerEnterprise.isOnDemandEnabled = false
            vpnManagerEnterprise.saveToPreferences(completionHandler: { [self] error in
                if let error = error {
                    print("Enterprise Save to Preferences Error: \(error)")
                } else {
                    print("Save successfully")
                    vpnManagerEnterprise.connection.stopVPNTunnel()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
                        self.updateUIOnMainThread()
                    }
                }
            })
        }

        UserDefaults.standard.set(nil, forKey: "StartDate")
        let reconnectVPN = UserDefaults.standard.bool(forKey: "reconnectVPN")
        if reconnectVPN {
            UserDefaults.standard.setValue(false, forKey: "reconnectVPN")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.connectTapped(nil)
            }
        }
    }



    // Notification Receiver Functions
    @objc func onVPNStatusChanged() {
        var status: NEVPNStatus
        status = vpnManagerEnterprise.connection.status

        print("VPN status : \(status)")

        if(status != .invalid){
            if(status == .connecting){
                startVPNFromServer = false
                UserDefaults.standard.set("Connecting", forKey: "VPNStatus")
            }else if(status == .connected){
                startVPNFromServer = false
                UserDefaults.standard.set("Connected", forKey: "VPNStatus")
            }else if(status == .disconnecting){
                UserDefaults.standard.set("Disconnecting", forKey: "VPNStatus")
            }else if(status == .disconnected){
                UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
                if(startVPNFromServer){
                    self.connectTapped(nil)
                }
            }
            UserDefaults.standard.synchronize()
            updateUIOnMainThread()
        }else{
            UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
            UserDefaults.standard.synchronize()
        }
    }

    @IBAction func statusTapped() {
        popView.isHidden = false

        popTapped = true

        if popTapped {
            imgArrow.image = UIImage(named: "x2ArrowUpGreen")
        } else {
            imgArrow.image = UIImage(named: "x2ArrowDownGreen")
        }
    }

    @IBAction func recent1Tapped() {
        let recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()

        let status = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if (status == "Connected" || status == "Connecting") {
            UserDefaults.standard.set(true, forKey: "reconnectVPN")
        }

        let city = appDelegate.getCityByID(cityID: recentArray[0])
        cityProtocol = (city?.type)!

//        print("connecting : ", city?.ipID!, cityProtocol)

        if cityProtocol == 5 {
            UserDefaults.standard.set(5, forKey: "selectedProtocol")
        } else {
            UserDefaults.standard.set(1, forKey: "selectedProtocol")
        }

        UserDefaults.standard.set(city?.ipID, forKey: "selectedServerID")
        NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UpdateProtocol"), object: nil)
        connect()
    }

    @IBAction func recent2Tapped() {
        let recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()

        let status = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if (status == "Connected" || status == "Connecting") {
            UserDefaults.standard.set(true, forKey: "reconnectVPN")
        }

        let city = appDelegate.getCityByID(cityID: recentArray[1])
        cityProtocol = (city?.type)!

//        print("connecting : ", city?.ipID!, cityProtocol)

        if cityProtocol == 5 {
            UserDefaults.standard.set(5, forKey: "selectedProtocol")
        } else {
            UserDefaults.standard.set(1, forKey: "selectedProtocol")
        }

        UserDefaults.standard.set(city?.ipID, forKey: "selectedServerID")
        NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UpdateProtocol"), object: nil)
        connect()
    }

    @IBAction func recent3Tapped() {
        let recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()

        let status = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if (status == "Connected" || status == "Connecting") {
            UserDefaults.standard.set(true, forKey: "reconnectVPN")
        }

        let city = appDelegate.getCityByID(cityID: recentArray[2])
        cityProtocol = (city?.type)!

//        print("connecting : ", city?.ipID!, cityProtocol)

        if cityProtocol == 5 {
            UserDefaults.standard.set(5, forKey: "selectedProtocol")
        } else {
            UserDefaults.standard.set(1, forKey: "selectedProtocol")
        }

        UserDefaults.standard.set(city?.ipID, forKey: "selectedServerID")
        NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UpdateProtocol"), object: nil)
        connect()
    }

    @IBAction func recent4Tapped() {
        let recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()

        let status = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if (status == "Connected" || status == "Connecting") {
            UserDefaults.standard.set(true, forKey: "reconnectVPN")
        }

        let city = appDelegate.getCityByID(cityID: recentArray[3])
        cityProtocol = (city?.type)!

//        print("connecting : ", city?.ipID!, cityProtocol)

        if cityProtocol == 5 {
            UserDefaults.standard.set(5, forKey: "selectedProtocol")
        } else {
            UserDefaults.standard.set(1, forKey: "selectedProtocol")
        }

        UserDefaults.standard.set(city?.ipID, forKey: "selectedServerID")
        NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UpdateProtocol"), object: nil)
        connect()
    }

    @IBAction func recent5Tapped() {
        let recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()

        let status = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if (status == "Connected" || status == "Connecting") {
            UserDefaults.standard.set(true, forKey: "reconnectVPN")
        }

        let city = appDelegate.getCityByID(cityID: recentArray[4])
        cityProtocol = (city?.type)!

//        print("connecting : ", city?.ipID!, cityProtocol)

        if cityProtocol == 5 {
            UserDefaults.standard.set(5, forKey: "selectedProtocol")
        } else {
            UserDefaults.standard.set(1, forKey: "selectedProtocol")
        }

        UserDefaults.standard.set(city?.ipID, forKey: "selectedServerID")
        NotificationCenter.default.post(name: Notification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UpdateProtocol"), object: nil)
        connect()
    }

    @IBAction func serverTapped() {
        tabBarController?.selectedIndex = 1
    }

    @IBAction func dismissTapped() {
        popView.isHidden = true

        popTapped = false

        let status = self.vpnManagerEnterprise.connection.status

        if(status == .connected){
            if popTapped {
                imgArrow.image = UIImage(named: "x2ArrowUpGreen")
            } else {
                imgArrow.image = UIImage(named: "x2ArrowDownGreen")
            }
        } else {
            if popTapped {
                imgArrow.image = UIImage(named: "x2ArrowUpOrange")
            } else {
                imgArrow.image = UIImage(named: "x2ArrowDownOrange")
            }
        }
    }
}
