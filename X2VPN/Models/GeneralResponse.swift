
struct GeneralResponse: Codable{

    let status: Bool
    let statusCode: Int
    let responseCode: Int
    var message: String

    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case responseCode = "response_code"
        case message = "message"
        case status = "status"
        case errors = "errors"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if(container.contains(.statusCode)){
            statusCode = try container.decode(Int.self, forKey: .statusCode)
        }else{
            statusCode = 0
        }


        if(container.contains(.responseCode)){
            responseCode = try container.decode(Int.self, forKey: .responseCode)
        }else{
            responseCode = 0
        }


        if(container.contains(.message)){
            message = try container.decode(String.self, forKey: .message)
        }else{
            message = ""
        }


        if(container.contains(.status)){
            status = try container.decode(Bool.self, forKey: .status)
        }else{
            status = false
        }


        if(container.contains(.errors)){
            let error = try container.decode(ErrorObj.self, forKey: .errors)
            if error.message != nil{
                let msg = error.message
                if msg.count > 0{
                    self.message = msg.first!
                }else{
                    self.message = ""
                }
            }

        }
    }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status, forKey: .status)
            try container.encode(statusCode, forKey: .statusCode)
            try container.encode(responseCode, forKey: .responseCode)
            try container.encode(message, forKey: .message)
        }
}
