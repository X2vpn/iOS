// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import Alamofire
import UICKeyChainStore
import OneSignal

@available(iOSApplicationExtension, unavailable)
class APIManager{

    let deviceNamesByCode : [String: String] = ["iPod1,1":"iPod Touch 1",
                                                "iPod2,1":"iPod Touch 2",
                                                "iPod3,1":"iPod Touch 3",
                                                "iPod4,1":"iPod Touch 4",
                                                "iPod5,1":"iPod Touch 5",
                                                "iPod7,1":"iPod Touch 6",
                                                "iPhone1,1":"iPhone",
                                                "iPhone1,2":"iPhone ",
                                                "iPhone2,1":"iPhone ",
                                                "iPhone3,1":"iPhone 4",
                                                "iPhone3,2":"iPhone 4",
                                                "iPhone3,3":"iPhone 4",
                                                "iPhone4,1":"iPhone 4s",
                                                "iPhone5,1":"iPhone 5",
                                                "iPhone5,2":"iPhone 5",
                                                "iPhone5,3":"iPhone 5c",
                                                "iPhone5,4":"iPhone 5c",
                                                "iPhone6,1":"iPhone 5s",
                                                "iPhone6,2":"iPhone 5s",
                                                "iPhone7,2":"iPhone 6",
                                                "iPhone7,1":"iPhone 6 Plus",
                                                "iPhone8,1":"iPhone 6s",
                                                "iPhone8,2":"iPhone 6s Plus",
                                                "iPhone8,4":"iPhone SE",
                                                "iPhone9,1": "iPhone 7",
                                                "iPhone9,3": "iPhone 7",
                                                "iPhone9,2": "iPhone 7 Plus",
                                                "iPhone9,4": "iPhone 7 Plus",
                                                "iPhone10,1": "iPhone 8",
                                                "iPhone10,2": "iPhone 8 Plus",
                                                "iPhone10,3": "iPhone X Global",
                                                "iPhone10,4": "iPhone 8",
                                                "iPhone10,5": "iPhone 8 Plus",
                                                "iPhone10,6": "iPhone X GSM",
                                                "iPhone11,2": "iPhone XS",
                                                "iPhone11,4": "iPhone XS Max",
                                                "iPhone11,6": "iPhone XS Max Global",
                                                "iPhone11,8": "iPhone XR",
                                                "iPhone12,1": "iPhone 11",
                                                "iPhone12,3": "iPhone 11 Pro",
                                                "iPhone12,5": "iPhone 11 Pro Max",
                                                "iPhone12,8": "iPhone SE 2nd Gen",
                                                "iPhone13,1": "iPhone 12 Mini",
                                                "iPhone13,2": "iPhone 12",
                                                "iPhone13,3": "iPhone 12 Pro",
                                                "iPhone13,4": "iPhone 12 Pro Max",
                                                "iPhone14,2": "iPhone 13 Pro",
                                                "iPhone14,3": "iPhone 13 Pro Max",
                                                "iPhone14,4": "iPhone 13 Mini",
                                                "iPhone14,5": "iPhone 13",
                                                "iPhone14,6": "iPhone SE 3rd Gen",
                                                "iPhone14,7": "iPhone 14",
                                                "iPhone14,8": "iPhone 14 Plus",
                                                "iPhone15,2": "iPhone 14 Pro",
                                                "iPhone15,3": "iPhone 14 Pro Max",
                                                "iPhone15,4": "iPhone 15",
                                                "iPhone15,5": "iPhone 15 Plus",
                                                "iPhone16,1": "iPhone 15 Pro",
                                                "iPhone16,2": "iPhone 15 Pro Max",
                                                "iPad2,1":"iPad 2",
                                                "iPad2,2":"iPad 2",
                                                "iPad2,3":"iPad 2",
                                                "iPad2,4":"iPad 2",
                                                "iPad3,1":"iPad 3",
                                                "iPad3,2":"iPad 3",
                                                "iPad3,3":"iPad 3",
                                                "iPad3,4":"iPad 4",
                                                "iPad3,5":"iPad 4",
                                                "iPad3,6":"iPad 4",
                                                "iPad4,1":"iPad Air",
                                                "iPad4,2":"iPad Air",
                                                "iPad4,3":"iPad Air",
                                                "iPad5,3":"iPad Air 2",
                                                "iPad5,4":"iPad Air 2",
                                                "iPad2,5":"iPad Mini",
                                                "iPad2,6":"iPad Mini",
                                                "iPad2,7":"iPad Mini",
                                                "iPad4,4":"iPad Mini 2",
                                                "iPad4,5":"iPad Mini 2",
                                                "iPad4,6":"iPad Mini 2",
                                                "iPad4,7":"iPad Mini 3",
                                                "iPad4,8":"iPad Mini 3",
                                                "iPad4,9":"iPad Mini 3",
                                                "iPad5,1":"iPad Mini 4",
                                                "iPad5,2":"iPad Mini 4",
                                                "iPad6,3":"iPad Pro",
                                                "iPad6,4":"iPad Pro",
                                                "iPad6,7":"iPad Pro",
                                                "iPad6,8":"iPad Pro",
                                                "AppleTV5,3":"Apple TV",
                                                "i386":"Simulator",
                                                "x86_64":"Simulator"

    ]

    static let shared = APIManager()

    func checkInternetAvailable() -> Bool {
        if let manager = NetworkReachabilityManager(){
            return manager.isReachable
        }else{
            return false
        }
    }

    //Refresh User Data
    func refreshUserData() {
        let keychain = UICKeyChainStore(service: "X2VPN")

        let userEmail = keychain.string(forKey: "userEmail")!
        let password = keychain.string(forKey: "password")!

        var udid = keychain.string(forKey: "UUID") ?? ""
        if udid.count == 0 {
            udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            keychain.setString(udid, forKey: "UUID")
        }

        let currentLocale = NSLocale.current as NSLocale
        let countryCode = currentLocale.object(forKey: .countryCode) as? String ?? ""

        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

        var sysinfo = utsname()
        uname(&sysinfo)
        let deviceModel = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
        let deviceModelString = deviceNamesByCode[deviceModel]

        let deviceName = String(bytes: Data(bytes: &sysinfo.nodename, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
        let osVersion = UIDevice.current.systemVersion

        let playerID = OneSignal.getDeviceState().userId ?? ""

        let url = "https://api.x2vpn.com/app-api-v1/login"

        let params: Parameters = [
            "username": userEmail,
            "pass": password,
            "udid": udid,
            "countryCode" : countryCode,
            "device_type": 2,
            "brand": "Apple",
            "vpnAppVersion" : appVersionString,
            "model" : deviceModelString ?? "N/A",
            "osName" : "iOS",
            "osVersion" : osVersion,
            "osPlatform" : "iOS",
            "isRooted" : "0",
            "deviceName" : deviceName,
            "app_id" : "1",
            "player_id" : playerID
        ]

        print("Login Post Data", params)

        AF.request(url, method: .post, parameters: params).responseString { response in
            print(response)
            switch response.result {
            case .success(let value):
                let delegate = UIApplication.shared.delegate as? AppDelegate
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let userData: User = try JSONDecoder().decode(User.self, from: jsonData)
                        print("login response: ", response)

                        if(userData.responseCode == 1){
                            delegate?.saveUserData(userData: userData)
                            NotificationCenter.default.post(name: Notification.Name("refreshUserData"), object: nil)
                        } else {
                            print("Login API Error : \(String(describing: userData.message))")
                        }
                    } catch {
                        print("Login Parse Error : \(error)")
                    }
                }else{
                    print("Login API Error : Failed, Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Login API Error : \(error)")
            }
        }
    }


    //Login API
    func loginAPI(userEmail: String, password: String, completion: @escaping (String, String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")

        var udid = keychain.string(forKey: "UUID") ?? ""
        if udid.count == 0 {
            udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            keychain.setString(udid, forKey: "UUID")
        }

        let currentLocale = NSLocale.current as NSLocale
        let countryCode = currentLocale.object(forKey: .countryCode) as? String ?? ""

        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

        var sysinfo = utsname()
        uname(&sysinfo)
        let deviceModel = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
        let deviceModelString = deviceNamesByCode[deviceModel]
        let deviceName = String(bytes: Data(bytes: &sysinfo.nodename, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
        let osVersion = UIDevice.current.systemVersion

        let playerID = OneSignal.getDeviceState().userId ?? ""

        let url = "https://api.x2vpn.com/app-api-v1/login"

        let params: Parameters = [
            "username": userEmail,
            "pass": password,
            "udid": udid,
            "countryCode" : countryCode,
            "device_type": 2,
            "brand": "Apple",
            "vpnAppVersion" : appVersionString,
            "model" : deviceModelString ?? "N/A",
            "osName" : "iOS",
            "osVersion" : osVersion,
            "osPlatform" : "iOS",
            "isRooted" : "0",
            "deviceName" : deviceName,
            "app_id" : "1",
            "player_id" : playerID
        ]

        print("Login Post Data", params)

        AF.request(url, method: .post, parameters: params).responseString { response in
            print(response)
            switch response.result {
            case .success(let value):
                let delegate = UIApplication.shared.delegate as? AppDelegate
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let userData: User = try JSONDecoder().decode(User.self, from: jsonData)
                        print("login response: ", response)

                        if(userData.responseCode == 1){
                            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastLoginTime")
                            delegate?.saveUserData(userData: userData)
                            completion("Success", userData.message!)
                            keychain.setString(userEmail, forKey: "userEmail")
                            keychain.setString(password, forKey: "password")

                            UserDefaults.standard.setValue(userEmail, forKey: "userEmail")
                            UserDefaults.standard.setValue(password, forKey: "password")

                            if let productList = userData.inAppData?.inAppPackages{
                                if(productList.count > 0){
                                    var skuIds : Set<String> = []
                                    for productData in productList {
                                        if(productData.skuID!.contains("com.rivernet.x2vpnios.")){
                                            skuIds.insert(productData.skuID!)
                                        }else{
                                            skuIds.insert("com.rivernet.x2vpnios.\(productData.skuID ?? "")")
                                        }
                                    }
                                    StoreManager.shared.loadInAppProducts(productList: skuIds)
                                }
                            }

                        } else {
                            if userData.responseCode == 100 {
                                completion("Not Verified", userData.message!)
                            } else {
                                completion("Failed", userData.message!)
                            }
                        }
                    } catch {
                        print("Login Parse Error : \(error)")
                        completion("Failed", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Login API Error : \(error)")
                completion("Failed", "Could not connect to server")
            }
        }
    }

    //Sign Up API
    func callSignUpAPI(email: String, password: String, fullname: String, completion: @escaping (String, String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")
        let url =  "https://api.x2vpn.com/app-api-v1/sign-up"

        let currentLocale = NSLocale.current as NSLocale
        let countryCode = currentLocale.object(forKey: .countryCode) as? String ?? ""

        let params : Parameters = [
            "username" : email,
            "password" : password,
            "password_confirmation" : password,
            "country" : countryCode,
            "fullname" : fullname,
        ]

        AF.request(url, method: .post, parameters: params).responseString { response in
            print("SignUp Response : \(response)")
            switch response.result {
            case .success(let value):
                print(value)
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                        if(data.responseCode == 1){
                            keychain.setString(email, forKey: "userEmail")
                            keychain.setString(fullname, forKey: "userName")
                            keychain.setString(password, forKey: "password")

                            UserDefaults.standard.set(fullname, forKey: "userName")
                            UserDefaults.standard.set(password, forKey: "password")
                            completion("Success", data.message)
                        }else{
                            completion("Failed", data.message)
                        }
                    } catch {
                        print("SignUp Parse Error : \(error.localizedDescription)")
                        completion("Failed", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("SignUp API Error : \(error.localizedDescription)")
                completion("Failed", "Could not connect to server")
            }
        }
    }

    //Sign Up Verification API
    func callSignUpVerificationAPI(username: String, token: String, completion: @escaping (String, String) -> Void) {
        let url = "https://api.x2vpn.com/app-api-v1/token-verification"

        let params : Parameters = [
            "username" : username,
            "token" : token,
            "token_type" : 1
        ]

        AF.request(url, method: .post, parameters: params).responseString { response in
            print("SignUp Verification Response : \(response)")
            switch response.result {
            case .success(let value):
                print(value)
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                        if(data.responseCode == 1){
                            completion("Success", data.message)
                        }else{
                            completion("Failed", data.message)
                        }
                    } catch {
                        print("SignUp Parse Error : \(error.localizedDescription)")
                        completion("Failed", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("SignUp Verification API Error : \(error.localizedDescription)")
                completion("Failed", "Could not connect to server")
            }
        }
    }

    //Resend OTP API
    func callResendApi(username: String, password: String, completion: @escaping (String, String) -> Void) {
        let urlResend = "https://api.x2vpn.com/app-api-v1/resend-email-verification"

        let params : Parameters = [
            "username" : username,
            "password" : password
        ]

//        print("Resend otp params:", params)

        AF.request(urlResend, method: .post, parameters: params).responseString { response in
            switch response.result {
            case .success(let value):

//                print("Resend response: ", response)
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let userData: User = try JSONDecoder().decode(User.self, from: jsonData)
                        if(userData.responseCode == 1){
                            completion("Success", userData.message!)
                        } else {
                            completion("Failed", userData.message!)
                        }
                    } catch {
                        print("Resend Parse Error : \(error)")
                        completion("Failed", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Resend API Error : \(error)")
                print("Resend data: ", response)
                completion("Failed", "Could not connect to server")
            }
        }
    }

    //Get Device List API
    func getDeviceList(completion: @escaping (String, [Device]) -> Void){
        let keychain = UICKeyChainStore(service: "X2VPN")

        let url = "https://api.x2vpn.com/app-api-v1/get-logged-in-devices"

        let params : Parameters = [
            "username" : keychain.string(forKey: "userEmail") ?? "",
            "pass" : keychain.string(forKey: "password") ?? "",
            "udid" : keychain.string(forKey: "UUID") ?? ""
        ]

//        print("Sent data, device api: ", params)

        AF.request(url, method: .post, parameters: params).responseString { response in
//            print("Device Info Response : \(response)")
            switch response.result {
            case .success(let value):
                if let jsonData = value.data(using: .utf8) {
                    do {
                      let deviceResponse: DeviceResponse = try JSONDecoder().decode(DeviceResponse.self, from: jsonData)
//                        print("Device Info Response2 : ", deviceResponse)
                      if(deviceResponse.responseCode == 1){
                          completion("Success", deviceResponse.data)
                      }else{
                          completion(deviceResponse.message!, [Device]())
                      }
                  } catch {
                      print("Device Info Parse Error : \(error)")
                      completion("JSON Parsing Error, Contact Admin", [Device]())
                  }
                }else{
                    completion("Invalid Response, Contact Admin", [Device]())
                }
            case .failure(let error):
                print("Device Info API Error : \(error.localizedDescription)")
                completion("Could not connect to server", [Device]())
            }
        }
    }

    //Change Pass API
    func callNewPassAPI(username: String, oldPassword: String, newPassword: String, completion: @escaping (String, String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")
        let urlReset = "https://api.x2vpn.com/app-api-v1/change-password"

        let params : Parameters = [
            "username" : username,
            "old_password" : oldPassword,
            "new_password" : newPassword
        ]

        AF.request(urlReset, method: .post, parameters: params).responseString { response in
            switch response.result {
            case .success(let value):
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let userData: User = try JSONDecoder().decode(User.self, from: jsonData)
                        if(userData.responseCode == 1){
                            completion("Success", userData.message!)
                            keychain.setString(newPassword, forKey: "password")
                            UserDefaults.standard.set(newPassword, forKey: "password")
                        } else {
                            completion("Failed", userData.message!)
                        }
                    } catch {
                        completion("Reset", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                completion("Reset", "Could not connect to server")
            }
        }
    }


    //Forget Password OTP Request API
    func callRestPassTokenRequest(username: String, completion: @escaping (String, String) -> Void) {
        let url = "https://api.x2vpn.com/app-api-v1/reset-password-token-request"

        let params : Parameters = [
            "username" : username
        ]

        AF.request(url, method: .post, parameters: params).responseString { response in
            print(" Verification Response : \(response)")
            switch response.result {
            case .success(let value):
                print(value)
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                        if(data.responseCode == 1){
                            completion("Success", data.message)
                        }else{
                            completion("Failed", data.message)
                        }
                    } catch {
                        print(" Parse Error : \(error.localizedDescription)")
                        completion("Failed", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Verification API Error : \(error.localizedDescription)")
                completion("Failed", "Could not connect to server")
            }
        }
    }

    //Forget Otp Verification API
    func callForgetVerificationAPI(username: String, token: String, completion: @escaping (String, String) -> Void) {
        let url = "https://api.x2vpn.com/app-api-v1/token-verification"

        let params : Parameters = [
            "username" : username,
            "token" : token,
            "token_type" : 1
        ]

//        print("Forget sent params: ", params)

        AF.request(url, method: .post, parameters: params).responseString { response in
//            print("Forget Password Verification Response : \(response)")
            switch response.result {
            case .success(let value):
                print(value)
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                        if(data.responseCode == 1){
                            completion("Success", data.message)
                        }else{
                            completion("Failed", data.message)
                        }
                    } catch {
                        print("SignUp Parse Error : \(error.localizedDescription)")
                        completion("Failed", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("SignUp Verification API Error : \(error.localizedDescription)")
                completion("Failed", "Could not connect to server")
            }
        }
    }

    //Set New Pass API
    func callNewPassAPI(username: String, password: String, token: String, password_confirmation: String, completion: @escaping (String, String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")
        let urlReset = "https://api.x2vpn.com/app-api-v1/reset-password"

        let params : Parameters = [
            "username" : username,
            "password" : password,
            "token" : token,
            "password_confirmation" : password_confirmation
        ]

        print("sent param: ", params)

        AF.request(urlReset, method: .post, parameters: params).responseString { response in

            print(response)

            switch response.result {
            case .success(let value):
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let userData: User = try JSONDecoder().decode(User.self, from: jsonData)
                        if(userData.responseCode == 1){
                            completion("Success", userData.message!)
                            keychain.setString(username, forKey: "userEmail")
                            keychain.setString(password, forKey: "password")
                            UserDefaults.standard.set(password, forKey: "password")
                        } else {
                            completion("Failed", userData.message!)
                        }
                    } catch {
                        print("Reset Parse Error : \(error)")
                        completion("Reset", "JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Failed", "Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Reset API Error : \(error)")
                print("Reset data: ", response)
                completion("Reset", "Could not connect to server")
            }
        }
    }

    func callPaymentAPI(userName: String, userEmail: String, receipt:Data, completion: @escaping(String) -> Void){
        let url = "https://api.x2vpn.com/app-api-v1/ios_in_app_purchase"

        var userID = userName
        if(userID == ""){
            let keychain = UICKeyChainStore(service: "X2VPN")
            userID = keychain.string(forKey: "userEmail") ?? ""
        }

        let pushUserID = OneSignal.getDeviceState().userId ?? ""

        let params : Parameters = [
            "username": userID,
            "contact_email": userEmail,
            "player_id": pushUserID,
            "receipt": receipt.base64EncodedString(options: []),
            "isSandbox": "1"
        ]

        AF.request(url, method: .post, parameters: params).responseString { response in
            print("Payment API Response : \(response)")
            switch response.result {
            case .success(let value):
                print(value)
                if let jsonData = value.data(using: .utf8) {
                  do {
                      let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                      if(data.responseCode == 1 || data.message.contains("Congratulation")){
                          completion("Success")
                      }else{
                          completion(data.message)
                      }
                  } catch {
                      print("Payment Parse Error : \(error)")
                      completion("JSON Parsing Error, Contact Admin")
                  }
                }else{
                    completion("Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Payment API Error : \(error.localizedDescription)")
                completion(error.localizedDescription)
            }
        }
    }

    func getWGConfigOn(serverID: Int, ipID: Int, completion: @escaping (String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")

        let url = "https://api.x2vpn.com/app-api-v1/wireguard-user-con"

        let params : Parameters = [
            "username" : keychain.string(forKey: "userEmail") ?? "",
            "pass" : keychain.string(forKey: "password") ?? "",
            "vpnserverId" : serverID,
            "ipId" : ipID,
            "connection_type" : 1,
            "isAdmin" : false
        ]

        print(params)

        AF.request(url, method: .post, parameters: params).responseString { response in
            switch response.result {
            case .success(let value):
//                print("Wireguard api response: ", value)
                completion(value)
            case .failure(let error):
                print("WG On Error : \(error)")
                completion("Could not connect to server")
            }
        }
    }

    func getWGConfigOff(serverID: Int, ipID: Int, completion: @escaping (String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")

        let url = "https://api.x2vpn.com/app-api-v1/wireguard-user-con"

        let params : Parameters = [
            "username" : keychain.string(forKey: "userEmail") ?? "",
            "pass" : keychain.string(forKey: "password") ?? "",
            "vpnserverId" : serverID,
            "ipId" : ipID,
            "connection_type" : 0,
            "isAdmin" : false
        ]

        AF.request(url, method: .post, parameters: params).responseString { response in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print("WG Off Error : \(error)")
                completion("Could not connect to server")
            }
        }
    }

    func getFeedbackInfo(completion: @escaping (String, FeedbackResponse?) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")
        let url = "\("https://api.x2vpn.com/app-api-v1/get-feedback-info")?username=\(keychain.string(forKey: "userEmail") ?? "")"

        AF.request(url, method: .get).responseString { response in
            print("Feedback Info Response : \(response)")
            switch response.result {
            case .success(let value):
                if let jsonData = value.data(using: .utf8) {
                  do {
                      let data: FeedbackResponse = try JSONDecoder().decode(FeedbackResponse.self, from: jsonData)
                      completion("Success", data)
                  } catch {
                      print("Feedback Info Parse Error : \(error.localizedDescription)")
                      completion("JSON Parsing Error, Contact Admin", nil)
                  }
                }else{
                    completion("Invalid Response, Contact Admin", nil)
                }
            case .failure(let error):
                print("Feedback Info API Error : \(error.localizedDescription)")
                completion(error.localizedDescription, nil)
            }
        }
    }

    func callFeedbackSubmitAPI(keywords: [String], emoji: String, feedback: String, completion: @escaping(String) -> Void){
        let url = "https://api.x2vpn.com/app-api-v1/save-customer-feedback"

        let keychain = UICKeyChainStore(service: "X2VPN")

        let params : Parameters = [
            "username": keychain.string(forKey: "userEmail") ?? "",
            "keywords": keywords,
            "selected_emoji": emoji,
            "feedback_text": feedback
        ]

//        print("feedback :", params)

        AF.request(url, method: .post, parameters: params).responseString { response in
//            print("Feedback Submit Response : \(response)")
            switch response.result {
            case .success(let value):
                if let jsonData = value.data(using: .utf8) {
                  do {
                      let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                      completion(data.message)
                  } catch {
                      print("Feedback Submit Parse Error : \(error.localizedDescription)")
                      completion("JSON Parsing Error, Contact Admin")
                  }
                }else{
                    completion("Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Feedback Submit API Error : \(error.localizedDescription)")
                completion(error.errorDescription!)
            }
        }
    }

    func callDeleteAccountAPI(completion: @escaping (String) -> Void) {
        let keychain = UICKeyChainStore(service: "X2VPN")

        let url =  "https://api.x2vpn.com/app-api-v1/remove-user"

        let params : Parameters = [
            "username" : keychain.string(forKey: "userEmail") ?? "",
            "pass" : keychain.string(forKey: "password") ?? "",
            "udid" : keychain.string(forKey: "UUID") ?? ""
        ]

        AF.request(url, method: .post, parameters: params).responseString { response in
            switch response.result {
            case .success(let value):
                if let jsonData = value.data(using: .utf8) {
                    do {
                        let data: GeneralResponse = try JSONDecoder().decode(GeneralResponse.self, from: jsonData)
                        if(data.responseCode == 1){
                            completion("Success")
                        }else{
                            completion(data.message)
                        }
                    } catch {
                        print("Delete Parse Error : \(error)")
                        completion("JSON Parsing Error, Contact Admin")
                    }
                }else{
                    completion("Invalid Response, Contact Admin")
                }
            case .failure(let error):
                print("Delete API Error : \(error)")
                completion("Could not connect to server")
            }
        }
    }
}
