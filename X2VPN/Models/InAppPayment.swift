struct InAppPayment: Codable{
    let inAppPackages: [InAppVPN]?
    let featureList: [String]?
    let featureData: InAppFeature?

    private enum CodingKeys: String, CodingKey {
        case inAppPackages = "iapp_ios_packages"
        case featureList = "premium_features_list"
        case featureData = "features_img_block"
    }

}
