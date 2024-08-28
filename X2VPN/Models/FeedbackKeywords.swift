struct FeedbackKeywords: Codable{

    let easyToUse: Int
    let easyConnect: Int
    let goodUI: Int
    let secure: Int
    let goodSpeed: Int
    let bestSupport: Int
    let bestForCalling: Int
    let bestAddOns: Int
    let good: Int
    let smoothConnection: Int
    let needImprovement: Int

    private enum CodingKeys: String, CodingKey {
        case easyToUse = "easy to use"
        case easyConnect = "easy connect"
        case goodUI = "good ui"
        case secure = "secure"
        case goodSpeed = "good speed"
        case bestSupport = "best support"
        case bestForCalling = "best for calling"
        case bestAddOns = "best addons"
        case good = "good"
        case smoothConnection = "smooth connection"
        case needImprovement = "need improvement"
    }

}
