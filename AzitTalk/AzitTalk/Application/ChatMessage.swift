//
//  ChatMessage.swift
//  NC1
//
//  Created by Shin Jae Ung on 2022/04/30.
//

import Foundation
import Firebase

struct ChatMessage: Equatable, Identifiable, Codable {
    let senderUID: String
    let displayName: String
    let text: String
    let time: Date
    var id: UUID = UUID()
    
    init(data: [String: Any]) {
        self.senderUID = data["senderUID"] as? String ?? ""
        self.displayName = data["senderDisplayName"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.time = (data["time"] as? Timestamp)?.dateValue() ?? Date()
    }
}
