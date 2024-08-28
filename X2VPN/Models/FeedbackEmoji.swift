struct FeedbackEmoji: Codable{

    let happy: Int
    let sad: Int
    let expressionless: Int
    let like: Int
    let love: Int

    private enum CodingKeys: String, CodingKey {
        case happy = "happy"
        case sad = "sad"
        case expressionless = "expressionless"
        case like = "like"
        case love = "love"
    }

}
