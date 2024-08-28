

struct Device: Codable{
    let id: Int?
    let pinlistId: Int?
    let username: String?
    let password: String?
    let udid: String?
    let playerID: String?
    let appID: Int?
    let type: Int?
    let appVersion: String?
    let brand: String?
    let model: String?
    let osName: String?
    let osVersion: String?
    let osPlatform: String?
    let rooted: Int?
    let created: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case pinlistId = "pinlist_id"
        case username
        case password
        case udid
        case playerID = "player_id"
        case appID = "app_id"
        case type = "device_type"
        case appVersion = "vpn_app_version"
        case brand = "brand"
        case model = "model"
        case osName = "os_name"
        case osVersion = "os_version"
        case osPlatform = "os_platform"
        case rooted = "is_rooted_phone"
        case created = "created_at"
    }
}
