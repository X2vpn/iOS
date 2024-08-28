struct InAppFeature: Codable{
    let imageURL: String?
    let href: String?

    private enum CodingKeys: String, CodingKey {
        case imageURL = "img_url"
        case href = "href"
    }
}
