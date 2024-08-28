//
//  ErrorObj.swift
//
//
//  Created by Riaz Hasan on 27/3/23.
//

struct ErrorObj: Codable {
    let message: [String]

    private enum CodingKeys: String, CodingKey {
        case message = "message"
    }
}
