import Foundation

struct generateIDModel: Codable {
    let statusCode: Int?
    let responseCode: Int?
    let message: String?
    let result: Result?

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case responseCode = "response_code"
        case message
        case result
    }

    struct Result: Codable {
        let accountId: String?

        enum CodingKeys: String, CodingKey {
            case accountId = "account_id"
        }
    }
}

