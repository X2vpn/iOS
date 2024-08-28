//E9XG8CJ2T2.com.kolpolok.Wireguard-VPN

import UIKit
import IQKeyboardManagerSwift
import UICKeyChainStore
import SwiftyPing
import StoreKit
import OneSignal

@available(iOS 13.0, *)

//@available(iOSApplicationExtension, unavailable)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var autoLogoutTimer: Timer?
    var mainList : [IPBundle]!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        OneSignal.setLocationShared(false)
        // One Signal Initialization
        self.initOneSignal(launchOptions: launchOptions)


        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true

        window?.overrideUserInterfaceStyle = .light

        // Check Pending In App Purchase
        self.checkPendingPurchase()

        manageInAPPProductsAndLoad()

        return true
    }

    func manageInAPPProductsAndLoad(){
        let skuid = ["com.rivernet.x2vpnios.1month","com.rivernet.x2vpnios.3month","com.rivernet.x2vpnios.6month","com.rivernet.x2vpnios.12month"]
        UserDefaults.standard.set(skuid, forKey: "Skuids")
        let skuSet = Set(skuid)
        StoreManager.shared.loadInAppProducts(productList: skuSet)
    }

    func initOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        let keychain = UICKeyChainStore(service: "X2VPN")

        let userEmail = keychain.string(forKey: "userEmail") ?? ""

        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("85819b30-e9cf-474a-b9ed-9e3e7869d8c0")

        if !userEmail.isEmpty {
            OneSignal.setEmail(userEmail)
        }

        if(UserDefaults.standard.object(forKey: "IsNotificationEnabled") != nil){
            if(UserDefaults.standard.bool(forKey: "IsNotificationEnabled")){
                OneSignal.disablePush(false)
            }else{
                OneSignal.disablePush(true)
            }
        }else{
            UserDefaults.standard.set(true, forKey: "IsNotificationEnabled")
            OneSignal.disablePush(false)
        }

        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        // This block gets called when notification received in foreground
        let notificationWillShowInForegroundBlock: OSNotificationWillShowInForegroundBlock = { notification, completion in
            if let notificationData = notification.additionalData as? NSDictionary {
//                if let pageName = notificationData["pageControl"] as? String{
//                    if(pageName.contains("http://") || pageName.contains("https://")){
//                        UserDefaults.standard.set(pageName, forKey: "LoginURL")
//                    }else{
//                        if(pageName == "Refresh"){
//                            let keyChainStore = UICKeyChainStore(service: "X2VPN")
//                            let userName = keyChainStore.string(forKey: "username")
//                            let password = keyChainStore.string(forKey: "password")
//                            if(userName != nil && password != nil){
//                                NetworkManager.shared.refreshUserData()
//                            }
//                        }else{
//                            let notice_status = UserDefaults.standard.string(forKey: "NoticeStatus") ?? ""
//                            if(notice_status == ""){
//                                let notice_type = self.getNoticeTypeFromPageName(pageName: pageName)
//                                let notice = notificationData.value(forKey: "notice") as? String ?? ""
//                                let start_after = (notificationData.value(forKey: "start_after") as? NSNumber)?.doubleValue ?? 0.0
//                                let end_after = (notificationData.value(forKey: "end_after") as? NSNumber)?.doubleValue ?? 0.0
//                                let lock_server_ids = notificationData.value(forKey: "lock_servers_id") as? String ?? ""
//
//                                self.scheduleNotice(noticeType: notice_type, notice: notice, startTime: start_after, endTime: end_after, lockServerIds: lock_server_ids)
//                            }
//                        }
//                    }
//                }
            }else{
                print("No Additional Data Available")
            }
            completion(notification)
        }
        OneSignal.setNotificationWillShowInForegroundHandler(notificationWillShowInForegroundBlock)

        // This block gets called when the user reacts to a notification received
        let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
            let notification: OSNotification = result.notification
            if let notificationData = notification.additionalData as? NSDictionary {
//                if let pageName = notificationData["pageControl"] as? String{
//                    if(pageName.count > 0){
//                        if(pageName.contains("http://") || pageName.contains("https://")){
//                            UserDefaults.standard.set(pageName, forKey: "LoginURL")
//                        }else{
//                            if(pageName == "Refresh"){
//                                let keyChainStore = UICKeyChainStore(service: "X2VPN")
//                                let userName = keyChainStore.string(forKey: "username")
//                                let password = keyChainStore.string(forKey: "password")
//                                if(userName != nil && password != nil){
//                                    NetworkManager.shared.refreshUserData()
//                                }
//                            }else if(pageName == "Refer"){
//                                UserDefaults.standard.set(true, forKey: "OpenReferFromPush")
//                            }else{
//                                let notice_status = UserDefaults.standard.string(forKey: "NoticeStatus") ?? ""
//                                if(notice_status == ""){
//                                    let notice_type = self.getNoticeTypeFromPageName(pageName: pageName)
//                                    let notice = notificationData.value(forKey: "notice") as? String ?? ""
//                                    let start_after = (notificationData.value(forKey: "start_after") as? NSNumber)?.doubleValue ?? 0.0
//                                    let end_after = (notificationData.value(forKey: "end_after") as? NSNumber)?.doubleValue ?? 0.0
//                                    let lock_server_ids = notificationData.value(forKey: "lock_servers_id") as? String ?? ""
//
//                                    self.scheduleNotice(noticeType: notice_type, notice: notice, startTime: start_after, endTime: end_after, lockServerIds: lock_server_ids)
//                                }
//                            }
//                        }
//                    }
//                }
            }else{
                print("No Additional Data Available")
            }
        }
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)

        // Get OneSignal Info
        if let deviceState = OneSignal.getDeviceState() {
           //Status of ability to send push notifications to the current device (See status chart below)
           let notificationPermissionStatus = deviceState.notificationPermissionStatus.rawValue
           print("Device's notification permission status: ", notificationPermissionStatus)

           // Get the OneSignal Push Player Id
           let userId = deviceState.userId
           print("OneSignal Push Player ID: ", userId ?? "called too early, not set yet")

           //Get device's push token identifier
           let pushToken = deviceState.pushToken
           print("Device's push token: ", pushToken ?? "called too early or not set yet" )

           // Get whether notifications are enabled on the device at the app level
           let hasNotificationPermission = deviceState.hasNotificationPermission
           print("Has device allowed push permission at some point: ", hasNotificationPermission)

           // The device's push subscription status
           let isSubscribed = deviceState.isSubscribed
           print("Device is subscribed to push notifications: ", isSubscribed)

           // Returns value of pushDisabled method
           let isPushDisabled = deviceState.isPushDisabled
           print("Push notifications are disabled with disablePush method: ", isPushDisabled)
        }

        //OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        // Save Notification
        self.addNotificationData(notificationData: userInfo)
    }

    func addNotificationData(notificationData: [AnyHashable: Any]){
        print("Notification Data : \(notificationData)")
        var offerArray = self.getNotificationData() ?? [Offer]()

        var id = ""
        var image = ""
        var title = ""
        var message = ""
        var link = ""

        if let custom = notificationData["custom"] as? NSDictionary{
            if let i = custom["i"] as? String{
                id = i
            }
            if let url = custom["u"] as? String{
                link = url
            }
        }
        if let att = notificationData["att"] as? NSDictionary{
            if let imageData = att["id"] as? String{
                image = imageData
            }
        }
        if let aps = notificationData["aps"] as? NSDictionary{
            if let alert = aps["alert"] as? NSDictionary{
                if let titleData = alert["title"] as? String{
                    title = titleData
                }
                if let messageData = alert["body"] as? String{
                    message = messageData
                }
            }
        }

        let offer = Offer(id: id, image: image, title: title, message: message, link: link, isSeen: false)
        var exist = false

        for offerData in offerArray{
            if(offerData.id == offer.id){
                exist = true
            }
        }
        if(!exist){
            offerArray.insert(offer, at: 0)
            // Do not add More than 20 items
            if(offerArray.count > 20){
                offerArray.remove(at: 20)
            }
            saveNotificationData(data: offerArray)
            NotificationCenter.default.post(name: Notification.Name("RefreshNotice"), object: nil)
        }
    }

    func saveNotificationData(data: [Offer]){
        let keychain = UICKeyChainStore(service: "X2VPN")
        let key = "NotificationData\(keychain.string(forKey: "userEmail") ?? "")"
        do{
            let writeData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(writeData, forKey: key)
        }catch{
            print("Error Saving Notification Data")
        }
    }

    func getNotificationData() -> [Offer]?{
        let keychain = UICKeyChainStore(service: "X2VPN")
        let key = "NotificationData\(keychain.string(forKey: "userEmail") ?? "")"
        if(UserDefaults.standard.object(forKey: key) != nil){
            do{
                let readData: Data = UserDefaults.standard.value(forKey: key) as! Data
                let data : [Offer] = try JSONDecoder().decode([Offer].self, from: readData)
                return data
            }catch{
                return [Offer]()
            }
        }else{
            return [Offer]()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication){
        print("Entering Background")
        self.stopAutoLogoutTimer()
    }

    func applicationWillEnterForeground(_ application: UIApplication){
        print("Entering Foreground")
        self.startAutoLogoutTimer()
    }

    func startAutoLogoutTimer(){
        if(autoLogoutTimer == nil){
            autoLogoutTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.forceLogout), userInfo: nil, repeats: true)
        }
    }

    @objc func forceLogout(){
        let currentDateTime = Date().timeIntervalSince1970
        let lastLoginTime = UserDefaults.standard.double(forKey: "LastLoginTime")
        let loggedInTime = currentDateTime - lastLoginTime
        let isLoggedIn = UserDefaults.standard.bool(forKey: "IsLoggedIn")
        let purchaseInProgress = UserDefaults.standard.bool(forKey: "PurchaseInProgress")
        if(isLoggedIn && loggedInTime > 43200 && !purchaseInProgress){ // 43200 = 12 Hours
            let vpnStatus = UserDefaults.standard.string(forKey: "VPNStatus") ?? "Disconnected"
            if(vpnStatus != "Connected" && vpnStatus != "Connecting"){
                UserDefaults.standard.set("Disconnected", forKey: "VPNStatus")
                UserDefaults.standard.set(false, forKey: "IsLoggedIn")

                DispatchQueue.main.async {
                    guard let window = UIApplication.shared.keyWindow else {
                        return
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "X2Login")
                    window.rootViewController = vc
                    let options: UIView.AnimationOptions = .transitionCrossDissolve
                    let duration: TimeInterval = 0.3
                    UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:nil)
                }
            }
        }
    }

    func stopAutoLogoutTimer(){
        if(autoLogoutTimer != nil){
            autoLogoutTimer?.invalidate()
            autoLogoutTimer = nil
        }

    }

//    func manageInAPPProductsAndLoad(skuids: String) -> Void{
//        UserDefaults.standard.set(skuids, forKey: "Skuids")
//        let userData = self.getuserData()
//        if(userData != nil){
//            if let productList = userData?.inAppData?.inAppPackages{
//                if(productList.count > 0){
//                    var skuIds : Set<String> = []
//                    for productData in productList {
//                        if(productData.skuID!.contains("com.rivernet.x2vpnios.")){
//                            skuIds.insert(productData.skuID!)
//                        }else{
//                            skuIds.insert("com.rivernet.x2vpnios.\(productData.skuID)")
//                        }
//                    }
//                    StoreManager.shared.loadInAppProducts(productList: skuIds)
//                }else{
//                    print("InAppData From Login Is Empty")
//                    var skuIds : Set<String> = []
//                    let skuidsArray = skuids.components(separatedBy: ",")
//                    for productID in skuidsArray {
//                        skuIds.insert("com.rivernet.x2vpnios.\(productID)")
//                    }
//                    StoreManager.shared.loadInAppProducts(productList: skuIds)
//                }
//            }else{
//                print("InAppData From Login Not Present")
//                var skuIds : Set<String> = []
//                let skuidsArray = skuids.components(separatedBy: ",")
//                for productID in skuidsArray {
//                    skuIds.insert("com.rivernet.x2vpnios.\(productID)")
//                }
//                StoreManager.shared.loadInAppProducts(productList: skuIds)
//            }
//        }else{
//            print("InAppData From Login Not Present")
//            var skuIds : Set<String> = []
//            let skuidsArray = skuids.components(separatedBy: ",")
//            for productID in skuidsArray {
//                skuIds.insert("com.rivernet.x2vpnios.\(productID)")
//            }
//            StoreManager.shared.loadInAppProducts(productList: skuIds)
//        }
//    }

    func checkPendingPurchase(){
        DispatchQueue.global(qos: .userInitiated).async {
            var array = self.getLocalReceiptData() ?? [Receipt]()
            let myGroup = DispatchGroup()
            for i in (0 ..< array.count).reversed(){
                myGroup.enter()
                let item = array[i]
                APIManager.shared.callPaymentAPI(userName: item.userID, userEmail: item.userEmail, receipt: item.receiptData, completion: {response in
                    print(response)
                    if(response == "Success"){
                        array.remove(at: i)
                    }
                    myGroup.resume()
                    myGroup.leave()
                })
                myGroup.wait()
            }
            myGroup.notify(queue: .main){
                self.saveLocalReceiptData(data: array)
            }
        }
    }

    func getLocalReceiptData() -> [Receipt]?{
        let keychain = UICKeyChainStore(service: "X2VPN")
        let key = "ReceiptData\(keychain.string(forKey: "accountId") ?? "")"
        if(UserDefaults.standard.object(forKey: key) != nil){
            do{
                let readData: Data = UserDefaults.standard.value(forKey: key) as! Data
                let data : [Receipt] = try JSONDecoder().decode([Receipt].self, from: readData)
                return data
            }catch{
                return [Receipt]()
            }
        }else{
            return [Receipt]()
        }
    }

    func saveLocalReceiptData(data: [Receipt]){
        let keychain = UICKeyChainStore(service: "X2VPN")
        let key = "ReceiptData\(keychain.string(forKey: "accountId") ?? "")"
        do{
            let writeData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(writeData, forKey: key)
        }catch{
            print("Error Saving Receipt Data")
        }
    }

    func changeTheme(isLight: Bool) {
        print("Changing theme to \(isLight ? "light" : "dark") mode")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                if isLight {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                } else {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }

    func saveUserData(userData: User){
        let keychain = UICKeyChainStore(service: "X2VPN")
        let key = "UserData\(keychain.string(forKey: "accountId") ?? "")"
        do{
            let writeData = try JSONEncoder().encode(userData)
            UserDefaults.standard.set(writeData, forKey: key)
        }catch{
            print("Error Saving User Data")
        }
    }

    func getuserData() -> User?{
        let keychain = UICKeyChainStore(service: "X2VPN")
        let key = "UserData\(keychain.string(forKey: "accountId") ?? "")"
        if(UserDefaults.standard.object(forKey: key) != nil){
            do{
                let readData: Data = UserDefaults.standard.value(forKey: key) as! Data
                let data : User = try JSONDecoder().decode(User.self, from: readData)
//                print("Saved user data in Appdelegate: ",data)
                return data
            }catch{
                print("Parse Error : \(error)")
                return nil
            }
        }else{
            return nil
        }
    }

    func addRecentServerData(cityID : String){
        var recentArray = UserDefaults.standard.stringArray(forKey: "recentServerLists") ?? [String]()
        if(!recentArray.contains(cityID)){
            recentArray.insert(cityID, at: 0)
            if(recentArray.count > 5){
                recentArray.remove(at: 5)
            }
        }
        print("recent added : \(recentArray.count)")
        UserDefaults.standard.setValue(recentArray, forKey: "recentServerLists")
    }

//    func getCityByID(cityID: String) -> IPBundle {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        let mainList = delegate?.getuserData()?.ipBundle ?? [IPBundle]()
//        for city in mainList{
//            if String(city.ipID) == cityID {
//                return city
//            }
//        }
//
//        print("recent list: ", mainList)
//
//        return mainList[0]
//
//    }

    func getCityByID(cityID: String) -> IPBundle? {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate,
              let mainList = delegate.getuserData()?.ipBundle else {
            return nil
        }

        for city in mainList {
            if String(describing: city.ipID) == cityID {
                return city
            }
        }

        print("recent list: ", mainList)

        // Return nil if no matching city is found
        return nil
    }

    func getFlagImage(countryCode: String) -> String?{
        var flagName = "";

        if (countryCode == "8") {
            flagName = "flag_albania"
        }else if(countryCode == "004"){
            flagName = "flag_afghanistan"
        }else if(countryCode == "012"){
            flagName = "flag_algeria"
        }else if(countryCode == "020"){
            flagName = "flag_andorra"
        }else if(countryCode == "024"){
            flagName = "flag_angola"
        }else if(countryCode == "032"){
            flagName = "flag_argentina"
        }else if(countryCode == "051"){
            flagName = "flag_armenia"
        }else if(countryCode == "533"){
            flagName = "flag_aruba"
        }else if(countryCode == "040"){
            flagName = "flag_austria"
        }else if(countryCode == "036"){
            flagName = "flag_australia"
        }else if(countryCode == "031"){
            flagName = "flag_azerbaijan"
        }else if(countryCode == "48"){
            flagName = "flag_bahrain"
        }else if(countryCode == "050"){
            flagName = "flag_bangladesh"
        }else if(countryCode == "112"){
            flagName = "flag_belarus"
        }else if(countryCode == "056"){
            flagName = "flag_belgium"
        }else if(countryCode == "84"){
            flagName = "flag_belize"
        }else if(countryCode == "204"){
            flagName = "flag_benin"
        }else if(countryCode == "064"){
            flagName = "flag_bhutan"
        }else if(countryCode == "68"){
            flagName = "flag_bolivia"
        }else if(countryCode == "070"){
            flagName = "flag_bosnia"
        }else if(countryCode == "072"){
            flagName = "flag_botswana"
        }else if(countryCode == "076"){
            flagName = "flag_brazil"
        }else if(countryCode == "96"){
            flagName = "flag_brunei"
        }else if(countryCode == "100"){
            flagName = "flag_bulgaria"
        }else if(countryCode == "854"){
            flagName = "flag_burkina_faso"
        }else if(countryCode == "104"){
            flagName = "flag_myanmar"
        }else if(countryCode == "108"){
            flagName = "flag_burundi"
        }else if(countryCode == "116"){
            flagName = "flag_cambodia"
        }else if(countryCode == "120"){
            flagName = "flag_cameroon"
        }else if(countryCode == "124"){
            flagName = "flag_canada"
        }else if(countryCode == "132"){
            flagName = "flag_cape_verde"
        }else if(countryCode == "140"){
            flagName = "flag_central_african_republic"
        }else if(countryCode == "148"){
            flagName = "flag_chad"
        }else if(countryCode == "152"){
            flagName = "flag_chile"
        }else if(countryCode == "156"){
            flagName = "flag_china"
        }else if(countryCode == "170"){
            flagName = "flag_colombia"
        }else if(countryCode == "174"){
            flagName = "flag_comoros"
        }else if(countryCode == "178"){
            flagName = "flag_republic_of_the_congo"
        }else if(countryCode == "180"){
            flagName = "flag_democratic_republic_of_the_congo"
        }else if(countryCode == "184"){
            flagName = "flag_cook_islands"
        }else if(countryCode == "188"){
            flagName = "flag_costa_rica"
        }else if(countryCode == "191"){
            flagName = "flag_croatia"
        }else if(countryCode == "192"){
            flagName = "flag_cuba"
        }else if(countryCode == "196"){
            flagName = "flag_cyprus"
        }else if(countryCode == "203"){
            flagName = "flag_czech_republic"
        }else if(countryCode == "208"){
            flagName = "flag_denmark"
        }else if(countryCode == "262"){
            flagName = "flag_djibouti"
        }else if(countryCode == "626"){
            flagName = "flag_timor_leste"
        }else if(countryCode == "218"){
            flagName = "flag_ecuador"
        }else if(countryCode == "818"){
            flagName = "flag_egypt"
        }else if(countryCode == "222"){
            flagName = "flag_el_salvador"
        }else if(countryCode == "226"){
            flagName = "flag_equatorial_guinea"
        }else if(countryCode == "232"){
            flagName = "flag_eritrea"
        }else if(countryCode == "233"){
            flagName = "flag_estonia"
        }else if(countryCode == "231"){
            flagName = "flag_ethiopia"
        }else if(countryCode == "238"){
            flagName = "flag_falkland_islands"
        }else if(countryCode == "234"){
            flagName = "flag_faroe_islands"
        }else if(countryCode == "242"){
            flagName = "flag_fiji"
        }else if(countryCode == "246"){
            flagName = "flag_finland"
        }else if(countryCode == "250"){
            flagName = "flag_france"
        }else if(countryCode == "258"){
            flagName = "flag_french_polynesia"
        }else if(countryCode == "266"){
            flagName = "flag_gabon"
        }else if(countryCode == "270"){
            flagName = "flag_gambia"
        }else if(countryCode == "268"){
            flagName = "flag_georgia"
        }else if(countryCode == "276"){
            flagName = "flag_germany"
        }else if(countryCode == "288"){
            flagName = "flag_ghana"
        }else if(countryCode == "292"){
            flagName = "flag_gibraltar"
        }else if(countryCode == "300"){
            flagName = "flag_greece"
        }else if(countryCode == "304"){
            flagName = "flag_greenland"
        }else if(countryCode == "320"){
            flagName = "flag_guatemala"
        }else if(countryCode == "324"){
            flagName = "flag_guinea"
        }else if(countryCode == "624"){
            flagName = "flag_guinea_bissau"
        }else if(countryCode == "328"){
            flagName = "flag_guyana"
        }else if(countryCode == "332"){
            flagName = "flag_haiti"
        }else if(countryCode == "340"){
            flagName = "flag_honduras"
        }else if(countryCode == "344"){
            flagName = "flag_hong_kong"
        }else if(countryCode == "348"){
            flagName = "flag_hungary"
        }else if(countryCode == "356"){
            flagName = "flag_india"
        }else if(countryCode == "360"){
            flagName = "flag_indonesia"
        }else if(countryCode == "364"){
            flagName = "flag_iran"
        }else if(countryCode == "368"){
            flagName = "flag_iraq"
        }else if(countryCode == "372"){
            flagName = "flag_ireland"
        }else if(countryCode == "833"){
            flagName = "flag_isleof_man"
        }else if(countryCode == "376"){
            flagName = "flag_israel"
        }else if(countryCode == "380"){
            flagName = "flag_italy"
        }else if(countryCode == "384"){
            flagName = "flag_cote_divoire"
        }else if(countryCode == "392"){
            flagName = "flag_japan"
        }else if(countryCode == "400"){
            flagName = "flag_jordan"
        }else if(countryCode == "398"){
            flagName = "flag_kenya"
        }else if(countryCode == "414"){
            flagName = "flag_kiribati"
        }else if(countryCode == "296"){
            flagName = "flag_kuwait"
        }else if(countryCode == "417"){
            flagName = "flag_kyrgyzstan"
        }else if(countryCode == "136"){
            flagName = "flag_cayman_islands"
        }else if(countryCode == "418"){
            flagName = "flag_laos"
        }else if(countryCode == "428"){
            flagName = "flag_latvia"
        }else if(countryCode == "422"){
            flagName = "flag_lebanon"
        }else if(countryCode == "426"){
            flagName = "flag_lesotho"
        }else if(countryCode == "430"){
            flagName = "flag_liberia"
        }else if(countryCode == "434"){
            flagName = "flag_libya"
        }else if(countryCode == "438"){
            flagName = "flag_liechtenstein"
        }else if(countryCode == "440"){
            flagName = "flag_lithuania"
        }else if(countryCode == "442"){
            flagName = "flag_luxembourg"
        }else if(countryCode == "450"){
            flagName = "flag_madagascar"
        }else if(countryCode == "454"){
            flagName = "flag_malawi"
        }else if(countryCode == "458"){
            flagName = "flag_malaysia"
        }else if(countryCode == "462"){
            flagName = "flag_maldives"
        }else if(countryCode == "466"){
            flagName = "flag_mali"
        }else if(countryCode == "470"){
            flagName = "flag_malta"
        }else if(countryCode == "584"){
            flagName = "flag_marshall_islands"
        }else if(countryCode == "478"){
            flagName = "flag_mauritania"
        }else if(countryCode == "480"){
            flagName = "flag_mauritius"
        }else if(countryCode == "175"){
            flagName = "flag_martinique"
        }else if(countryCode == "474"){
            flagName = "flag_martinique"
        }else if(countryCode == "484"){
            flagName = "flag_mexico"
        }else if(countryCode == "583"){
            flagName = "flag_micronesia"
        }else if(countryCode == "498"){
            flagName = "flag_moldova"
        }else if(countryCode == "492"){
            flagName = "flag_monaco"
        }else if(countryCode == "496"){
            flagName = "flag_mongolia"
        }else if(countryCode == "499"){
            flagName = "flag_of_montenegro"
        }else if(countryCode == "504"){
            flagName = "flag_morocco"
        }else if(countryCode == "508"){
            flagName = "flag_mozambique"
        }else if(countryCode == "516"){
            flagName = "flag_namibia"
        }else if(countryCode == "520"){
            flagName = "flag_nauru"
        }else if(countryCode == "524"){
            flagName = "flag_nepal"
        }else if(countryCode == "528"){
            flagName = "flag_netherlands"
        }else if(countryCode == "540"){
            flagName = "flag_new_caledonia"
        }else if(countryCode == "554"){
            flagName = "flag_new_zealand"
        }else if(countryCode == "558"){
            flagName = "flag_nicaragua"
        }else if(countryCode == "562"){
            flagName = "flag_niger"
        }else if(countryCode == "566"){
            flagName = "flag_nigeria"
        }else if(countryCode == "570"){
            flagName = "flag_niue"
        }else if(countryCode == "410"){
            flagName = "flag_north_korea"
        }else if(countryCode == "578"){
            flagName = "flag_norway"
        }else if(countryCode == "512"){
            flagName = "flag_oman"
        }else if(countryCode == "586"){
            flagName = "flag_pakistan"
        }else if(countryCode == "585"){
            flagName = "flag_palau"
        }else if(countryCode == "591"){
            flagName = "flag_panama"
        }else if(countryCode == "598"){
            flagName = "flag_papua_new_guinea"
        }else if(countryCode == "600"){
            flagName = "flag_paraguay"
        }else if(countryCode == "604"){
            flagName = "flag_peru"
        }else if(countryCode == "608"){
            flagName = "flag_philippines"
        }else if(countryCode == "612"){
            flagName = "flag_pitcairn_islands"
        }else if(countryCode == "616"){
            flagName = "flag_poland"
        }else if(countryCode == "620"){
            flagName = "flag_portugal"
        }else if(countryCode == "630"){
            flagName = "flag_puerto_rico"
        }else if(countryCode == "634"){
            flagName = "flag_qatar"
        }else if(countryCode == "642"){
            flagName = "flag_romania"
        }else if(countryCode == "643"){
            flagName = "flag_russian_federation"
        }else if(countryCode == "646"){
            flagName = "flag_rwanda"
        }else if(countryCode == "652"){
            flagName = "flag_saint_barthelemy"
        }else if(countryCode == "882"){
            flagName = "flag_samoa"
        }else if(countryCode == "674"){
            flagName = "flag_san_marino"
        }else if(countryCode == "678"){
            flagName = "flag_sao_tome_and_principe"
        }else if(countryCode == "682"){
            flagName = "flag_saudi_arabia"
        }else if(countryCode == "686"){
            flagName = "flag_senegal"
        }else if(countryCode == "688"){
            flagName = "flag_serbia"
        }else if(countryCode == "690"){
            flagName = "flag_seychelles"
        }else if(countryCode == "694"){
            flagName = "flag_sierra_leone"
        }else if(countryCode == "702"){
            flagName = "flag_singapore"
        }else if(countryCode == "703"){
            flagName = "flag_slovakia"
        }else if(countryCode == "705"){
            flagName = "flag_slovenia"
        }else if(countryCode == "90"){
            flagName = "flag_soloman_islands"
        }else if(countryCode == "706"){
            flagName = "flag_somalia"
        }else if(countryCode == "710"){
            flagName = "flag_south_africa"
        }else if(countryCode == "408"){
            flagName = "flag_south_korea"
        }else if(countryCode == "724"){
            flagName = "flag_spain"
        }else if(countryCode == "144"){
            flagName = "flag_sri_lanka"
        }else if(countryCode == "654"){
            flagName = "flag_saint_helena"
        }else if(countryCode == "666"){
            flagName = "flag_saint_pierre"
        }else if(countryCode == "729"){
            flagName = "flag_sudan"
        }else if(countryCode == "740"){
            flagName = "flag_suriname"
        }else if(countryCode == "752"){
            flagName = "flag_sweden"
        }else if(countryCode == "756"){
            flagName = "flag_switzerland"
        }else if(countryCode == "760"){
            flagName = "flag_syria"
        }else if(countryCode == "158"){
            flagName = "flag_taiwan"
        }else if(countryCode == "762"){
            flagName = "flag_tajikistan"
        }else if(countryCode == "834"){
            flagName = "flag_tanzania"
        }else if(countryCode == "764"){
            flagName = "flag_thailand"
        }else if(countryCode == "768"){
            flagName = "flag_togo"
        }else if(countryCode == "772"){
            flagName = "flag_tokelau"
        }else if(countryCode == "776"){
            flagName = "flag_tonga"
        }else if(countryCode == "788"){
            flagName = "flag_tunisia"
        }else if(countryCode == "792"){
            flagName = "flag_turkey"
        }else if(countryCode == "795"){
            flagName = "flag_turkmenistan"
        }else if(countryCode == "798"){
            flagName = "flag_tuvalu"
        }else if(countryCode == "784"){
            flagName = "flag_uae"
        }else if(countryCode == "800"){
            flagName = "flag_uganda"
        }else if(countryCode == "826"){
            flagName = "flag_united_kingdom"
        }else if(countryCode == "804"){
            flagName = "flag_ukraine"
        }else if(countryCode == "858"){
            flagName = "flag_uruguay"
        }else if(countryCode == "840"){
            flagName = "flag_united_states_of_america"
        }else if(countryCode == "860"){
            flagName = "flag_uzbekistan"
        }else if(countryCode == "548"){
            flagName = "flag_vanuatu"
        }else if(countryCode == "862"){
            flagName = "flag_venezuela"
        }else if(countryCode == "704"){
            flagName = "flag_vietnam"
        }else if(countryCode == "876"){
            flagName = "flag_wallis_and_futuna"
        }else if(countryCode == "887"){
            flagName = "flag_yemen"
        }else if(countryCode == "894"){
            flagName = "flag_zambia"
        }else if(countryCode == "716"){
            flagName = "flag_zimbabuwe"
        }else if(countryCode == "660"){
            flagName = "flag_anguilla"
        }else if(countryCode == "28"){
            flagName = "flag_antigua_and_barbuda"
        }else if(countryCode == "044"){
            flagName = "flag_bahamas"
        }else if(countryCode == "052"){
            flagName = "flag_barbados"
        }else if(countryCode == "92"){
            flagName = "flag_british_virgin_islands"
        }else if(countryCode == "212"){
            flagName = "flag_dominica"
        }else if(countryCode == "214"){
            flagName = "flag_dominican_republic"
        }else if(countryCode == "308"){
            flagName = "flag_grenada"
        }else if(countryCode == "388"){
            flagName = "flag_jamaica"
        }else if(countryCode == "500"){
            flagName = "flag_montserrat"
        }else if(countryCode == "659"){
            flagName = "flag_saint_kitts_and_nevis"
        }else if(countryCode == "662"){
            flagName = "flag_saint_lucia"
        }else if(countryCode == "670"){
            flagName = "flag_saint_vicent_and_the_grenadines"
        }else if(countryCode == "780"){
            flagName = "flag_trinidad_and_tobago"
        }else if(countryCode == "796"){
            flagName = "flag_turks_and_caicos_islands"
        }else if(countryCode == "850"){
            flagName = "flag_us_virgin_islands"
        }else if(countryCode == "728"){
            flagName = "flag_south_sudan"
        }else if(countryCode == "9999"){
            flagName = "flag_south_sudan"
        }else if(countryCode == "1111"){
            flagName = "flag_south_sudan"
        }else{
            flagName = "flag_united_kingdom"
        }
        return flagName
    }

}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
