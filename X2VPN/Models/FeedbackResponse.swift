struct FeedbackResponse: Codable{

//    let feedbackKeywords: FeedbackKeywords
    let feedbackEmoji: FeedbackEmoji

    private enum CodingKeys: String, CodingKey {
//        case feedbackKeywords = "feedbackKeywords"
        case feedbackEmoji = "feedbackEmoji"
    }

}
