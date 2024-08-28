import Foundation

struct Receipt: Codable{

    let userID: String
    let userEmail: String
    let productID: String
    let receiptData: Data

    init(userID: String, userEmail: String, productID: String, receiptData: Data) {
        self.userID = userID
        self.userEmail = userEmail
        self.productID = productID
        self.receiptData = receiptData
    }
}
