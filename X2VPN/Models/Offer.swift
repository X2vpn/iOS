
struct Offer: Codable{

    let id: String
    let image: String
    let title: String
    let message: String
    let link: String
    var isSeen: Bool

    init(id: String, image: String, title: String, message: String, link: String, isSeen: Bool) {
        self.id = id
        self.image = image
        self.title = title
        self.message = message
        self.link = link
        self.isSeen = isSeen
    }

}
