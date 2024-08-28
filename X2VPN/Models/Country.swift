struct Country: Codable{

    let countryName: String
    let countryImage: String
    let cities: [IPBundle]
    var isExpanded: Bool

    init(countryName: String, countryImage: String, cities: [IPBundle], isExpanded: Bool) {
        self.countryName = countryName
        self.countryImage = countryImage
        self.cities = cities
        self.isExpanded = isExpanded
    }
}
