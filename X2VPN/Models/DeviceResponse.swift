struct DeviceResponse: Codable {
    let responseCode: Int?
    let result, message: String?
    let statusCode: Int?
    let data: [Device]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case result, message
        case statusCode = "status_code"
        case data
    }
}
