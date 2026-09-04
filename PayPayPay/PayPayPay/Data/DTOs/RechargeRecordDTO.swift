import Foundation

struct RechargeRecordDTO: Codable, Identifiable {
    var id = UUID()
    var state: Int?
    var money: String?
    var createTime: String?
    var modifyTime: String

}
