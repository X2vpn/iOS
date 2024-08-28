struct User : Codable{
    var responseCode: Int?
    var message: String?
    var ipBundle: [IPBundle]?
    var expireInDays: Int?
    var validityDate: String?
    var expiryDate: String?
    var userType: Int?
    var subscriptionPlanName: String?
    var fullname: String?
    var showBanner: String?
    var showFullScreen: String?
    var userStatus: String?
    var accountID: String?
    var contactEmail: String?
    var websiteUrl: String?
    var enablePromotionalBanner: Int?
    var bannerData: BannerData?
    var inAppData: InAppPayment?
//    var antiTracker: String?
//    var adultContentBlocker: String?


    private enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case message
        case ipBundle = "ip_bundle"
        case expireInDays = "expire_in_days"
        case validityDate = "validity_date"
        case expiryDate = "expired_at"
        case userType = "user_type"
        case subscriptionPlanName = "subscription_plan_name"
        case fullname
        case showBanner = "show_banner"
        case showFullScreen = "show_full_screen"
        case userStatus = "user_status"
        case accountID = "account_id"
        case contactEmail = "contact_email"
        case websiteUrl = "website_url"
        case enablePromotionalBanner = "enable_promotional_banner"
        case bannerData = "promotional_banner_details"
        case inAppData = "in_app_payment_page_data"
//        case antiTracker = "anti_tracker"
//        case adultContentBlocker = "adult_content_blocker"
      }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if(container.contains(.responseCode)){
            responseCode = try container.decode(Int.self, forKey: .responseCode)
        }else{
            responseCode = 0
        }

        if(container.contains(.message)){
            message = try container.decode(String.self, forKey: .message)
        }else{
            message = ""
        }

        if(container.contains(.ipBundle)){
            ipBundle = try container.decode([IPBundle].self, forKey: .ipBundle)
        }else{
            ipBundle = nil
        }

        if(container.contains(.expireInDays)){
            do{
                expireInDays = try container.decode(Int.self, forKey: .expireInDays)
            }catch DecodingError.typeMismatch{
                expireInDays = 0
            }
        }else{
            expireInDays = 0
        }

        if(container.contains(.validityDate)){
            validityDate = try container.decode(String.self, forKey: .validityDate)
        }else{
            validityDate = ""
        }

        if(container.contains(.expiryDate)){
            expiryDate = try container.decode(String.self, forKey: .expiryDate)
        }else{
            expiryDate = ""
        }

        if(container.contains(.userType)){
            userType = try container.decode(Int.self, forKey: .userType)
        }else{
            userType = 0
        }

        if(container.contains(.showBanner)){
            showBanner = try container.decode(String.self, forKey: .showBanner)
        }else{
            showBanner = ""
        }

        if(container.contains(.fullname)){
            fullname = try container.decode(String.self, forKey: .fullname)
        }else{
            fullname = ""
        }

        if(container.contains(.subscriptionPlanName)){
            subscriptionPlanName = try container.decode(String.self, forKey: .subscriptionPlanName)
        }else{
            subscriptionPlanName = ""
        }

        if(container.contains(.showFullScreen)){
            showFullScreen = try container.decode(String.self, forKey: .showFullScreen)
        }else{
            showFullScreen = ""
        }

        if(container.contains(.userStatus)){
            userStatus = try container.decode(String.self, forKey: .userStatus)
        }else{
            userStatus = ""
        }

        if(container.contains(.accountID)){
            accountID = try container.decode(String.self, forKey: .accountID)
        }else{
            accountID = ""
        }

        if(container.contains(.contactEmail)){
            contactEmail = try container.decode(String.self, forKey: .contactEmail)
        }else{
            contactEmail = ""
        }

        if(container.contains(.websiteUrl)){
            websiteUrl = try container.decode(String.self, forKey: .websiteUrl)
        }else{
            websiteUrl = ""
        }

        if(container.contains(.enablePromotionalBanner)){
            enablePromotionalBanner = try container.decode(Int.self, forKey: .enablePromotionalBanner)
        }else{
            enablePromotionalBanner = 0
        }

        if(container.contains(.bannerData)){
            do{
                bannerData = try container.decode(BannerData.self, forKey: .bannerData)
            }catch DecodingError.typeMismatch{
                bannerData = nil
            }
        }else{
            bannerData = nil
        }

        if(container.contains(.inAppData)){
            inAppData = try container.decode(InAppPayment.self, forKey: .inAppData)
        }else{
            inAppData = nil
        }
//
//        if(container.contains(.antiTracker)){
//            antiTracker = try container.decode(String.self, forKey: .antiTracker)
//        }else{
//            antiTracker = ""
//        }
//
//        if(container.contains(.adultContentBlocker)){
//            adultContentBlocker = try container.decode(String.self, forKey: .adultContentBlocker)
//        }else{
//            adultContentBlocker = ""
//        }

//        if(container.contains(.antiTracker)){
//            do{
//                antiTracker = try container.decode(String.self, forKey: .antiTracker)
//            }catch DecodingError.typeMismatch{
//                antiTracker = nil
//            }
//        }else{
//            antiTracker = nil
//        }
//
//        if(container.contains(.adultContentBlocker)){
//            do{
//                adultContentBlocker = try container.decode(String.self, forKey: .adultContentBlocker)
//            }catch DecodingError.typeMismatch{
//                adultContentBlocker = nil
//            }
//        }else{
//            adultContentBlocker = nil
//        }
    }
}
