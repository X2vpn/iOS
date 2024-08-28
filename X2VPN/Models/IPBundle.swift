

struct IPBundle: Codable{
    let bundleName: String?
    let ipName: String?
    let ip: String?
    let network: Int?
    let config: String?
    let typeTxt: String?
    let type: Int?
    let priority: Int?
    let countryCode: String?
    let vpnServerID: Int?
    let connectionType: Int?
    let ipID: Int?
    let platform: String?
    let countryName: String?
    let isStreamingServer: Int?
    let isGamingServer: Int?
    let isFreeServer: Int?
    let isHighSpeedServer: Int?
    let isAdBlockServer: Int?
    let lat: String?
    let lng: String?
    let serverCity: String?

    private enum CodingKeys: String, CodingKey {
        case bundleName
        case ipName
        case ip
        case network
        case config
        case typeTxt
        case type
        case priority
        case countryCode
        case vpnServerID = "vpn_server_id"
        case connectionType = "connection_type"
        case ipID = "ip_id"
        case platform
        case countryName = "countryName"
        case isStreamingServer = "is_online_stream"
        case isGamingServer = "is_gaming"
        case isFreeServer = "is_free"
        case isHighSpeedServer = "is_fast_server"
        case isAdBlockServer = "is_adblocker"
        case lat
        case lng
        case serverCity = "server_city"
    }
}
