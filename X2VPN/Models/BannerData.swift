struct BannerData: Codable{
    let bannerBGColor: String?
    let bannerText: String?
    let bannerUserType: String?

    private enum CodingKeys: String, CodingKey {
        case bannerBGColor = "promotional_banner_bg_color"
        case bannerText = "promotional_banner_text"
        case bannerUserType = "promotional_banner_user_type"
    }
}
