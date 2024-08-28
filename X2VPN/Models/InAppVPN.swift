struct InAppVPN: Codable{
    let id: Int?
    let name: String?
    let price: Double?
    let skuID: String?
    let subTitle: String?
    let highlightedText: String?
    let featureTitle: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case skuID = "sku_ids"
        case subTitle = "sub_title"
        case highlightedText = "highlighted_text"
        case featureTitle = "feature_title"
    }
}
