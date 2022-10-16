//
//  Caching.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/22.
//

import Foundation

final class Caching {
    static let shared = Caching()
    static let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    private init() {
        guard let url = Caching.url else { return }
        if !FileManager.default.fileExists(atPath: url.appendingPathComponent("messages").path) {
            try? FileManager.default.createDirectory(at: url.appendingPathComponent("messages"), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func fetchMessages(from: Int, to: Int) -> [ChatMessage] {
        guard to >= 0 && to >= from,
            let url = Caching.url else { return [] }
        var from = from
        if from < 0 { from = 0 }
        var chatMessages: [ChatMessage] = []
        for number in from...to {
            let messageURL = url.appendingPathComponent("messages/\(number).json")
            guard let jsonData = try? Data(contentsOf: messageURL) else { continue }
            guard let message = try? Caching.decoder.decode(ChatMessage.self, from: jsonData) else { continue }
            chatMessages.append(message)
        }
        return chatMessages
    }
    
    func saveMessage(_ message: ChatMessage, to number: Int) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Caching.url else { return }
            if let encodedData = try? Caching.encoder.encode(message) {
                try? encodedData.write(to: url.appendingPathComponent("messages/\(number).json"))
            }
        }
    }
}
