// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit
import UICKeyChainStore

class X2TabBarServerList: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var optionView1: UIView!
    @IBOutlet weak var optionView2: UIView!
    @IBOutlet weak var optionView3: UIView!
    @IBOutlet weak var optionView4: UIView!
    @IBOutlet weak var connectedView: UIView!

    @IBOutlet weak var lblOption1: UILabel!
    @IBOutlet weak var lblOption2: UILabel!
    @IBOutlet weak var lblOption3: UILabel!
    @IBOutlet weak var lblOption4: UILabel!
    @IBOutlet weak var lblConnectedServer: UILabel!
    @IBOutlet weak var imgConnectedServer: UIImageView!

    @IBOutlet weak var connectedViewHC: NSLayoutConstraint!
    @IBOutlet weak var tvCountry: UITableView!
    @IBOutlet weak var tfSearch: UITextField!

    var selectedTab = 1
    private var selectedServer: IPBundle!
    private var allServer = [IPBundle]()

    private var isInSearchMode = false
    private var searchText = ""

    private var allCountryArray = [Country]()
    private var allSectionArray = [Country]()
//    var cityArray = [IPBundle]()

    private var searchServerArray = [Country]()
    var recentCityArray = [IPBundle]()
    var favouriteCityArray = [IPBundle]()
    var allCityArray = [IPBundle]()

    private var hasLastCombinedRegular = false
    private var hasLastCombinedSearch = false
    private var lastCombinedRegularIndex = 0
    private var lastCombinedSearchIndex = 0

    private var hasFavSectionRegular = false
    private var hasFavSectionSearch = false
    private var favSectionRegularIndex = 0
    private var favSectionSearchIndex = 0
    private var favSectionRegularRowCount = 0
    private var favSectionSearchRowCount = 0

//    private var recentServerArray = [Int]()
    private var favServerArray = [Int]()

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        searchView.layer.cornerRadius = 10
        optionView1.layer.cornerRadius = 10
        optionView2.layer.cornerRadius = 10
        optionView3.layer.cornerRadius = 10
        optionView4.layer.cornerRadius = 10
        imgConnectedServer.layer.cornerRadius = 6
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }

    override func viewDidLoad() {
        super.viewDidLoad()


        tfSearch.delegate = self
        tvCountry.delegate = self
        tvCountry.dataSource = self



        let keychain = UICKeyChainStore(service: "X2VPN")
        favServerArray = UserDefaults.standard.array(forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)") as? [Int] ?? [Int]()

//        recentServerArray = UserDefaults.standard.array(forKey: "recentServerLists\(keychain.string(forKey: "userEmail")!)") as? [Int] ?? [Int]()

        updateConnectedView()
        updateUI()

        initializeRegularTableView()

        NotificationCenter.default.addObserver(self, selector: #selector(self.initializeRegularTableView), name: NSNotification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.initializeSearchTableView), name: NSNotification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable), name: NSNotification.Name("UpdateServer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateConnectedView), name: NSNotification.Name("VPNStatusChanged"), object: nil)
    }

    @objc func updateTable() {

        if selectedTab == 1{
            countryTapped()//tvCountry.reloadData()
        } else if selectedTab == 2 {
            locationTapped()
        } else if selectedTab == 3 {
            favoriteTapped()
        } else if selectedTab == 4{
            specialTapped()
        }
    }

    @objc func updateConnectedView() {
        let vpnStatus = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
        if(vpnStatus == "Connected" || vpnStatus == "Connecting"){
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

            if(selectedServer != nil){
                imgConnectedServer.image = UIImage(named: (delegate?.getFlagImage(countryCode: selectedServer.countryCode!))!)
                let countryName = selectedServer.countryName
                var serverName = selectedServer.ipName

                serverName!.append(countryName!)

                lblConnectedServer.text = serverName

                connectedViewHC.constant = 94
                connectedView.isHidden = false
            } else {
                connectedViewHC.constant = 0
                connectedView.isHidden = true
            }
        }else{
            connectedViewHC.constant = 0
            connectedView.isHidden = true
        }

    }

    func getSelectedServer() -> IPBundle?{
        let selectedServerID = UserDefaults.standard.integer(forKey: "selectedServerID")
        print("selected server id on getSelectedServer:", selectedServerID)

        var serverFound = false
        for server in allServer{
            if(server.ipID == selectedServerID){
                serverFound = true
                print("server found server list: ", serverFound)
                return server
            }
        }

        print("server found server list: ", serverFound)
        print("all server count: ", allServer.count)
        return allServer.first
    }

    func updateUI() {
        if selectedTab == 1 {
            optionView1.backgroundColor = UIColor(named: "E6E0E9")
            optionView2.backgroundColor = UIColor .clear
            optionView3.backgroundColor = UIColor .clear
            optionView4.backgroundColor = UIColor .clear
            lblOption1.textColor = UIColor(named: "000000")
            lblOption2.textColor = UIColor(named: "79767D")
            lblOption3.textColor = UIColor(named: "79767D")
            lblOption4.textColor = UIColor(named: "79767D")
        } else if selectedTab == 2 {
            optionView2.backgroundColor = UIColor(named: "E6E0E9")
            optionView1.backgroundColor = UIColor .clear
            optionView3.backgroundColor = UIColor .clear
            optionView4.backgroundColor = UIColor .clear
            lblOption2.textColor = UIColor(named: "000000")
            lblOption1.textColor = UIColor(named: "79767D")
            lblOption3.textColor = UIColor(named: "79767D")
            lblOption4.textColor = UIColor(named: "79767D")
        } else if selectedTab == 3 {
            optionView3.backgroundColor = UIColor(named: "E6E0E9")
            optionView1.backgroundColor = UIColor .clear
            optionView2.backgroundColor = UIColor .clear
            optionView4.backgroundColor = UIColor .clear
            lblOption3.textColor = UIColor(named: "000000")
            lblOption1.textColor = UIColor(named: "79767D")
            lblOption2.textColor = UIColor(named: "79767D")
            lblOption4.textColor = UIColor(named: "79767D")
        } else if selectedTab == 4 {
            optionView4.backgroundColor = UIColor(named: "E6E0E9")
            optionView1.backgroundColor = UIColor .clear
            optionView2.backgroundColor = UIColor .clear
            optionView3.backgroundColor = UIColor .clear
            lblOption4.textColor = UIColor(named: "000000")
            lblOption1.textColor = UIColor(named: "79767D")
            lblOption2.textColor = UIColor(named: "79767D")
            lblOption3.textColor = UIColor(named: "79767D")
        }
    }

    @objc func initializeRegularTableView() {
        // Main Array
//        allCountryArray = [Country]()

        allCityArray.removeAll()
        allCountryArray.removeAll()

        var countryCodeArray = [String]()

        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()
        for server in serverList{
            if((server.platform == "all" || server.platform == "ios") && isProtocolEnabled(type: server.type!)){
                if(!countryCodeArray.contains(server.countryCode!)){
                    countryCodeArray.append(server.countryCode!)
                }
            }
        }

        print(countryCodeArray)

        for countryCode in countryCodeArray{
            for server in serverList{
                if((server.platform == "all" || server.platform == "ios") && isProtocolEnabled(type: server.type!) && countryCode == server.countryCode){
                    allCityArray.append(server)
                }
            }

            if(allCityArray.count > 0){
                let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: allCityArray)
                let serverArray = Country(countryName: allCityArray[0].countryName!, countryImage: delegate?.getFlagImage(countryCode: allCityArray[0].countryCode!) ?? "", cities: sortedCityArray!, isExpanded: false)
                allCountryArray.append(serverArray)
            }
            allCityArray.removeAll()
        }

        print(allCountryArray)


//        print("Servers: ", allCityArray.count, allCountryArray.count, UserDefaults.standard.value(forKey: "selectedProtocol") ?? 5)
    }

    func isProtocolEnabled(type:Int) -> Bool{
        let protocolType: Int = UserDefaults.standard.value(forKey: "selectedProtocol") as? Int ?? 5
        if(type == 1 || type == 6){
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

    func sortInnerServerAlphabeticallyWithPriority(array: [IPBundle]?) -> [IPBundle]? {
        let alphabaticallySortedArray = array!.sorted { (object1, object2) -> Bool in
            let ipName1 = object1.ipName
            let ipName2 = object2.ipName
            return (ipName1!.localizedCaseInsensitiveCompare(ipName2!) == .orderedAscending)
        }

        return alphabaticallySortedArray.sorted(by: { $0.priority! < $1.priority! })
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var country: Country!

        if(isInSearchMode){
            country = searchServerArray[section]
        }else{
            if selectedTab == 1{
                country = allCountryArray[section]
            } else if selectedTab == 4 {
                country = allSectionArray[section]
            }
        }

        let width = tvCountry.frame.size.width

        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        headerView.tag = section

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 101
        imageView.image = UIImage(named: country.countryImage)
        imageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true

        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = UIColor(named: "1D1B20")
        name.font = UIFont(name: "OpenSans-Semibold", size: 14)
        name.tag = 102
        name.text = country.countryName

        let arrowView = UIImageView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.contentMode = .scaleAspectFit
        arrowView.tag = 100
        if(country.isExpanded){
            arrowView.image = UIImage(named: "x2ArrowUpBlack")
        }else{
            arrowView.image = UIImage(named: "x2ArrowDownBlack")
        }
        arrowView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        arrowView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        headerView.addSubview(imageView)
        headerView.addSubview(name)
        headerView.addSubview(arrowView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-0-[iv]-20-[name]-10-[av]-0-|", options: [.alignAllCenterY], metrics: nil, views: ["iv": imageView, "name": name, "av": arrowView]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[name]-10-|", options: [], metrics: nil, views: ["name": name]))
        NSLayoutConstraint.activate(constraints)

        let headerTapped = UITapGestureRecognizer(target: self, action: #selector(self.sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(headerTapped)

        return headerView
    }


    @IBAction func countryTapped() {
        selectedTab = 1
        tvCountry.reloadData()
        updateUI()
    }

    @IBAction func locationTapped() {
        selectedTab = 2
        allCityArray.removeAll()

        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()

        for server in serverList{
            if((server.platform == "all" || server.platform == "ios") && isProtocolEnabled(type: server.type!)){
                allCityArray.append(server)
            }
        }

        if allCityArray.count == 0 {
            showToast(message: "List is empty")
        }

        print("Location section array count: ", allCityArray.count)

        tvCountry.reloadData()
        updateUI()
    }

    @IBAction func favoriteTapped() {
        selectedTab = 3
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()

        favouriteCityArray.removeAll()

        for server in serverList {
            if favServerArray.contains(server.ipID!) && isProtocolEnabled(type: server.type!){
                favouriteCityArray.append(server)
            }
        }

        if favouriteCityArray.count == 0 {
            showToast(message: "List is empty")
        }

        print("Fav section array count: ", allSectionArray.count)

        tvCountry.reloadData()
        updateUI()
    }

    @IBAction func specialTapped() {
        selectedTab = 4

        // Main Array
        allSectionArray = [Country]()


        var highSpeedCityArray = [IPBundle]()
        var adBlockerCityArray = [IPBundle]()
        var gamingCityArray = [IPBundle]()
        var streamingCityArray = [IPBundle]()

        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()
        for server in serverList{
            if((server.platform == "all" || server.platform == "ios") && isProtocolEnabled(type: server.type!)){

                if(server.isGamingServer == 1){
                    gamingCityArray.append(server)
                }

                if(server.isStreamingServer == 1){
                    streamingCityArray.append(server)
                }
                if(server.isAdBlockServer == 1){
                    adBlockerCityArray.append(server)
                }

                if(server.isStreamingServer == 1){
                    streamingCityArray.append(server)
                }

                if(server.isHighSpeedServer == 1){
                    highSpeedCityArray.append(server)
                }
            }
        }

        if(gamingCityArray.count > 0){
            hasLastCombinedRegular = true
            lastCombinedRegularIndex = lastCombinedRegularIndex + 1
            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: gamingCityArray)
            let gamingServerArray = Country(countryName: "Gaming", countryImage: "x2Games", cities: sortedCityArray!, isExpanded: false)
            allSectionArray.append(gamingServerArray)
        }

        if(streamingCityArray.count > 0){
            hasLastCombinedRegular = true
            lastCombinedRegularIndex = lastCombinedRegularIndex + 1
            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: streamingCityArray)
            let streamingServerArray = Country(countryName: "Streaming ", countryImage: "x2Streaming", cities: sortedCityArray!, isExpanded: false)
            allSectionArray.append(streamingServerArray)
        }

        if(adBlockerCityArray.count > 0){
            hasLastCombinedRegular = true
            lastCombinedRegularIndex = lastCombinedRegularIndex + 1
            favSectionRegularIndex = favSectionRegularIndex + 1
            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: adBlockerCityArray)
            let adBlockerServerArray = Country(countryName: "Ad Blocker", countryImage: "x2Adblocker", cities: sortedCityArray!, isExpanded: false)
            allSectionArray.append(adBlockerServerArray)
        }

        if(streamingCityArray.count > 0){
            hasLastCombinedRegular = true
            lastCombinedRegularIndex = lastCombinedRegularIndex + 1
            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: streamingCityArray)
            let streamingServerArray = Country(countryName: "Movie and Series ", countryImage: "x2Movies", cities: sortedCityArray!, isExpanded: false)
            allSectionArray.append(streamingServerArray)
        }

        if(highSpeedCityArray.count > 0){
            hasLastCombinedRegular = true
            lastCombinedRegularIndex = lastCombinedRegularIndex + 1
            favSectionRegularIndex = favSectionRegularIndex + 1
            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: highSpeedCityArray)
            let highSpeedServerArray = Country(countryName: "High Speed", countryImage: "x2HighSpeed", cities: sortedCityArray!, isExpanded: false)
            allSectionArray.append(highSpeedServerArray)
        }

        print("Special section array count: ", allSectionArray.count)

        if allSectionArray.count == 0 {
            showToast(message: "List is empty")
        }

        tvCountry.reloadData()
        updateUI()
    }



    // Table View Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if(isInSearchMode){
            return searchServerArray.count
        }else{
            if selectedTab == 1 {
                return allCountryArray.count
            } else if selectedTab == 4 {
                return allSectionArray.count
            } else {
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedTab == 1 || selectedTab == 4 {
            return 50
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isInSearchMode){
            if(searchServerArray[section].isExpanded){
                return searchServerArray[section].cities.count
            }else{
                return 0
            }
        }else{
            if selectedTab == 1 {
                if(allCountryArray[section].isExpanded){
                    return allCountryArray[section].cities.count
                }else{
                    return 0
                }
            } else if selectedTab == 2 {
                if allCityArray.count != 0 {
                    return allCityArray.count
                } else {
                    return 0
                }
            } else if selectedTab == 4 {
                if(allSectionArray[section].isExpanded){
                    return allSectionArray[section].cities.count
                }else{
                    return 0
                }
            } else{
                if favouriteCityArray.count != 0 {
                    return favouriteCityArray.count
                } else {
                    return 0
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let keychain = UICKeyChainStore(service: "X2VPN")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        var country: Country!
        var cell: UITableViewCell!

        if(isInSearchMode){
            country = searchServerArray[indexPath.section]
        }else{
            if selectedTab == 1 {
                country = allCountryArray[indexPath.section]
            } else if selectedTab == 4 {
                country = allSectionArray[indexPath.section]
            }
        }

        if selectedTab == 1{
            cell = self.tvCountry.dequeueReusableCell(withIdentifier: "CellForCountry") as! CellForCountry
        } else if (selectedTab == 2) {
            cell = self.tvCountry.dequeueReusableCell(withIdentifier: "CellForLocation") as! CellForLocation
        }else if (selectedTab == 3) {
            cell = self.tvCountry.dequeueReusableCell(withIdentifier: "CellForFav") as! CellForFav
        } else if (selectedTab == 4) {
            cell = self.tvCountry.dequeueReusableCell(withIdentifier: "CellForCountry") as! CellForCountry
        }

        if let CellForCountry = cell as? CellForCountry {
            let server = country.cities[indexPath.row]

            if(server.ipID == UserDefaults.standard.integer(forKey: "selectedServerID")){
                CellForCountry.imgSelected.image = UIImage(named: "x2ConnectedServer")
            }else{
                CellForCountry.imgSelected.image = UIImage(named: "x2SelectedN")
            }

            CellForCountry.lblCity.text = server.ipName

            if(favServerArray.contains(server.ipID!)){
                CellForCountry.btnFav.setImage(UIImage(named: "x2Fav"), for: .normal)
            }else{
                CellForCountry.btnFav.setImage(UIImage(named: "x2FavN"), for: .normal)
            }

            CellForCountry.favTapped = {
                if let index = self.favServerArray.firstIndex(of: server.ipID!) {
                    self.favServerArray.remove(at: index)
                    UserDefaults.standard.set(self.favServerArray, forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)")
                    CellForCountry.btnFav.setImage(UIImage(named: "x2FavN"), for: .normal)
                }else{
                    self.favServerArray.append(server.ipID!)
                    CellForCountry.btnFav.setImage(UIImage(named: "x2Fav"), for: .normal)
                    UserDefaults.standard.set(self.favServerArray, forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)")
                }

                UserDefaults.standard.synchronize()
                self.tvCountry.reloadData()
            }

            CellForCountry.serverTapped = {
                UserDefaults.standard.set(server.ipID, forKey: "selectedServerID")
                print("Selected server all server: ", server.ipID!)

                UserDefaults.standard.synchronize()
                self.tvCountry.reloadData()
                self.callConnectionTask()
                self.tabBarController?.selectedIndex = 0
            }

        } else if let CellForLocation = cell as? CellForLocation {
            CellForLocation.imgCountry.image = UIImage(named: (delegate?.getFlagImage(countryCode: allCityArray[indexPath.row].countryCode!))!)
            CellForLocation.imgCountry.layer.cornerRadius = 6
            CellForLocation.lblCountry.text = allCityArray[indexPath.row].countryName
            CellForLocation.lblCity.text = "\(allCityArray[indexPath.row].ipName ?? "")\(",")"

            if(allCityArray[indexPath.row].ipID == UserDefaults.standard.integer(forKey: "selectedServerID")){
                CellForLocation.imgSelected.image = UIImage(named: "x2ConnectedServer")
            }else{
                CellForLocation.imgSelected.image = UIImage(named: "x2SelectedN")
            }

            CellForLocation.serverTapped = { [self] in
                UserDefaults.standard.set(allCityArray[indexPath.row].ipID, forKey: "selectedServerID")
                print("Selected server recent server: ", allCityArray[indexPath.row].ipID!)

                UserDefaults.standard.synchronize()
                self.tvCountry.reloadData()
                self.callConnectionTask()
                self.tabBarController?.selectedIndex = 0
            }

        } else if let CellForFav = cell as? CellForFav {
            CellForFav.imgCountry.image = UIImage(named: (delegate?.getFlagImage(countryCode: favouriteCityArray[indexPath.row].countryCode!))!)
            CellForFav.imgCountry.layer.cornerRadius = 6
            CellForFav.lblCountry.text = favouriteCityArray[indexPath.row].countryName
            CellForFav.lblCity.text = "\(favouriteCityArray[indexPath.row].ipName ?? "")\(",")"

            if(favServerArray.contains(favouriteCityArray[indexPath.row].ipID!)){
                CellForFav.btnFav.setImage(UIImage(named: "x2Fav"), for: .normal)
            }else{
                CellForFav.btnFav.setImage(UIImage(named: "x2FavN"), for: .normal)
            }
//
            CellForFav.favTapped = { [self] in
                if let index = self.favServerArray.firstIndex(of: (favouriteCityArray[indexPath.row].ipID!)) {
                    self.favServerArray.remove(at: index)
                    UserDefaults.standard.set(self.favServerArray, forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)")
                }else{
                    self.favServerArray.append(favouriteCityArray[indexPath.row].ipID!)
                    UserDefaults.standard.set(self.favServerArray, forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)")
                }


                UserDefaults.standard.synchronize()
                favoriteTapped()
            }

            CellForFav.serverTapped = { [self] in
                UserDefaults.standard.set(favouriteCityArray[indexPath.row].ipID, forKey: "selectedServerID")
                print("Selected server fav server: ", favouriteCityArray[indexPath.row].ipID!)

                UserDefaults.standard.synchronize()
                self.callConnectionTask()
                self.tabBarController?.selectedIndex = 0
            }
        }else if let CellForCountry = cell as? CellForCountry {
            let server = country.cities[indexPath.row]

            if(server.ipID == UserDefaults.standard.integer(forKey: "selectedServerID")){
                CellForCountry.imgSelected.image = UIImage(named: "x2ConnectedServer")
            }else{
                CellForCountry.imgSelected.image = UIImage(named: "x2SelectedN")
            }

            CellForCountry.lblCity.text = server.ipName

            if(favServerArray.contains(server.ipID!)){
                CellForCountry.btnFav.setImage(UIImage(named: "x2Fav"), for: .normal)
            }else{
                CellForCountry.btnFav.setImage(UIImage(named: "x2FavN"), for: .normal)
            }

            CellForCountry.favTapped = {
                if let index = self.favServerArray.firstIndex(of: server.ipID!) {
                    self.favServerArray.remove(at: index)
                    UserDefaults.standard.set(self.favServerArray, forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)")
                    CellForCountry.btnFav.setImage(UIImage(named: "x2FavN"), for: .normal)
                }else{
                    self.favServerArray.append(server.ipID!)
                    CellForCountry.btnFav.setImage(UIImage(named: "x2Fav"), for: .normal)
                    UserDefaults.standard.set(self.favServerArray, forKey: "FavouriteServerList\(keychain.string(forKey: "userEmail")!)")
                }

                UserDefaults.standard.synchronize()
                self.tvCountry.reloadData()
            }

            CellForCountry.serverTapped = {
                UserDefaults.standard.set(server.ipID, forKey: "selectedServerID")
                print("Selected server all server: ", server.ipID!)

                UserDefaults.standard.synchronize()
                self.tvCountry.reloadData()
                self.callConnectionTask()
                self.tabBarController?.selectedIndex = 0
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    @objc func sectionHeaderTapped(_ gestureRecognizer: UITapGestureRecognizer?) {
        let indexPath = IndexPath(row: 0, section: gestureRecognizer?.view?.tag ?? 0)
        var collapsed = false
        if(isInSearchMode){
            collapsed = searchServerArray[indexPath.section].isExpanded
            searchServerArray[indexPath.section].isExpanded = !collapsed
        }else{
            if selectedTab == 1 {
                collapsed = allCountryArray[indexPath.section].isExpanded
                allCountryArray[indexPath.section].isExpanded = !collapsed
            } else {
                collapsed = allSectionArray[indexPath.section].isExpanded
                allSectionArray[indexPath.section].isExpanded = !collapsed
            }
        }
        tvCountry.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
    }

    func isRowPresentInTableView(row: Int, section: Int) -> Bool {
        if section < tvCountry.numberOfSections {
            if row < tvCountry.numberOfRows(inSection: section) {
                return true
            }
        }
        return false
    }

    // Search TextField Function
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let range = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: range, with: string)
        searchText = newText.lowercased()
        if(searchText == ""){
            isInSearchMode = false
        }else{
            isInSearchMode = true
            initializeSearchTableView()
        }
        tvCountry.reloadData()
        return true
    }

    @objc func initializeSearchTableView(){
        // Main Array
        searchServerArray = [Country]()

        // Temporary Array
        var highSpeedCityArray = [IPBundle]()
        var adBlockerCityArray = [IPBundle]()
        var gamingCityArray = [IPBundle]()
        var countryCodeArray = [String]()

        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()
        for server in serverList{
            if((server.countryName!.lowercased().contains(searchText) || server.ipName!.lowercased().contains(searchText)) && isProtocolEnabled(type: server.type!)){
                if(server.platform == "all" || server.platform == "ios"){

//                    if(server.isHighSpeedServer == 1){
//                        highSpeedCityArray.append(server)
//                    }
//
//                    if(server.isAdBlockServer == 1){
//                        adBlockerCityArray.append(server)
//                    }
//
//                    if(server.isGamingServer == 1){
//                        gamingCityArray.append(server)
//                    }

                    if(!countryCodeArray.contains(server.countryCode!)){
                        countryCodeArray.append(server.countryCode!)
                    }
                }
            }
        }

//        if(highSpeedCityArray.count > 0){
//            hasLastCombinedSearch = true
//            lastCombinedSearchIndex = lastCombinedSearchIndex + 1
//            favSectionSearchIndex = favSectionSearchIndex + 1
//            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: highSpeedCityArray)
//            let highSpeedServerArray = Country(countryName: "Fast Server", countryImage: "crabFastServer", cities: sortedCityArray!, isExpanded: false)
//            searchServerArray.append(highSpeedServerArray)
//        }
//
//        if(adBlockerCityArray.count > 0){
//            hasLastCombinedSearch = true
//            lastCombinedSearchIndex = lastCombinedSearchIndex + 1
//            favSectionSearchIndex = favSectionSearchIndex + 1
//            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: adBlockerCityArray)
//            let adBlockerServerArray = Country(countryName: "Ad Blocker ", countryImage: "crabAdBlocker", cities: sortedCityArray!, isExpanded: false)
//            searchServerArray.append(adBlockerServerArray)
//        }
//        if(gamingCityArray.count > 0){
//            hasLastCombinedSearch = true
//            lastCombinedSearchIndex = lastCombinedSearchIndex + 1
//            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: gamingCityArray)
//            let gamingServerArray = Country(countryName: "Gaming Server", countryImage: "crabGaming", cities: sortedCityArray!, isExpanded: false)
//            searchServerArray.append(gamingServerArray)
//        }

        for countryCode in countryCodeArray{
            var cityArray = [IPBundle]()
            for server in serverList{
                if((server.platform == "all" || server.platform == "ios") && ((server.countryName?.lowercased().contains(searchText))! || server.ipName!.lowercased().contains(searchText)) && isProtocolEnabled(type: server.type!) && countryCode == server.countryCode){
                    cityArray.append(server)
                }
            }
            if(cityArray.count > 0){
                let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: cityArray)
                let serverArray = Country(countryName: cityArray[0].countryName!, countryImage: delegate?.getFlagImage(countryCode: cityArray[0].countryCode!) ?? "", cities: sortedCityArray!, isExpanded: false)
                searchServerArray.append(serverArray)
            }
        }
    }


    func refreshSearchArray(){
        // Main Array
        var searchServerArray = [Country]()

        // Refresh Temp Data
        hasLastCombinedSearch = false
        lastCombinedSearchIndex = 0
        hasFavSectionSearch = false
        favSectionSearchIndex = 0
        favSectionSearchRowCount = 0

        // Temporary Array
        var highSpeedCityArray = [IPBundle]()
        var adBlockerCityArray = [IPBundle]()
        var gamingCityArray = [IPBundle]()
        var countryCodeArray = [String]()

        let delegate = UIApplication.shared.delegate as? AppDelegate
        let serverList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()
        for server in serverList{
            if((server.countryName!.lowercased().contains(searchText) || server.ipName!.lowercased().contains(searchText)) && isProtocolEnabled(type: server.type!)){
                if(server.platform == "all" || server.platform == "ios"){

//                    if(server.isHighSpeedServer == 1){
//                        highSpeedCityArray.append(server)
//                    }
//
//                    if(server.isAdBlockServer == 1){
//                        adBlockerCityArray.append(server)
//                    }
//
//                    if(server.isGamingServer == 1){
//                        gamingCityArray.append(server)
//                    }

                    if(!countryCodeArray.contains(server.countryCode!)){
                        countryCodeArray.append(server.countryCode!)
                    }
                }
            }
        }

//        if(highSpeedCityArray.count > 0){
//            hasLastCombinedSearch = true
//            lastCombinedSearchIndex = lastCombinedSearchIndex + 1
//            favSectionSearchIndex = favSectionSearchIndex + 1
//            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: highSpeedCityArray)
//            let highSpeedServerArray = Country(countryName: "Fast Server", countryImage: "crabFastServer", cities: sortedCityArray!, isExpanded: self.isSearchArraySectionExpanded(section: "Fast Server"))
//            searchServerArray.append(highSpeedServerArray)
//        }
//
//        if(adBlockerCityArray.count > 0){
//            hasLastCombinedSearch = true
//            lastCombinedSearchIndex = lastCombinedSearchIndex + 1
//            favSectionSearchIndex = favSectionSearchIndex + 1
//            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: adBlockerCityArray)
//            let adBlockerServerArray = Country(countryName: "Ad Blocker", countryImage: "crabAdBlocker", cities: sortedCityArray!, isExpanded: self.isSearchArraySectionExpanded(section: "Ad Blocker"))
//            searchServerArray.append(adBlockerServerArray)
//        }
//
//        if(gamingCityArray.count > 0){
//            hasLastCombinedSearch = true
//            lastCombinedSearchIndex = lastCombinedSearchIndex + 1
//            let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: gamingCityArray)
//            let gamingServerArray = Country(countryName: "Gaming Server", countryImage: "crabGaming", cities: sortedCityArray!, isExpanded: self.isSearchArraySectionExpanded(section: "Gaming Server"))
//            searchServerArray.append(gamingServerArray)
//        }

        for countryCode in countryCodeArray{
            var cityArray = [IPBundle]()
            for server in serverList{
                if((server.platform == "all" || server.platform == "ios") && (server.countryName!.lowercased().contains(searchText) || server.ipName!.lowercased().contains(searchText)) && isProtocolEnabled(type: server.type!) && countryCode == server.countryCode){
                    cityArray.append(server)
                }
            }
            if(cityArray.count > 0){
                let sortedCityArray = sortInnerServerAlphabeticallyWithPriority(array: cityArray)
                let serverArray = Country(countryName: cityArray[0].countryName!, countryImage: delegate?.getFlagImage(countryCode: cityArray[0].countryCode!) ?? "", cities: sortedCityArray!, isExpanded: self.isSearchArraySectionExpanded(section: cityArray[0].countryName!))
                searchServerArray.append(serverArray)
            }
        }

        self.searchServerArray = searchServerArray
    }

    func isRegularArraySectionExpanded(section: String) -> Bool{
        if selectedTab == 1 {
            for country in allCountryArray{
                if(country.countryName == section){
                    return country.isExpanded
                }
            }
        } else {
            for country in allSectionArray{
                if(country.countryName == section){
                    return country.isExpanded
                }
            }
        }
        return false
    }

    func isSearchArraySectionExpanded(section: String) -> Bool{
        for country in searchServerArray{
            if(country.countryName == section){
                return country.isExpanded
            }
        }
        return false
    }

    func callConnectionTask() {
        let status = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"


        print("vpn status on serverlist: ", status)

        if (status == "Connected" || status == "Connecting") {
            UserDefaults.standard.set(true, forKey: "reconnectVPN")
        }

        NotificationCenter.default.post(name: Notification.Name("ConnectVPN"), object: nil)

    }
}
