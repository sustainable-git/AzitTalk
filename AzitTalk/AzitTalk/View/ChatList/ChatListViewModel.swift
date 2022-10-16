//
//  ChatListViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/22.
//

import SwiftUI

final class ChatListViewModel: ObservableObject {
    @Published var isUserCurrentlyLoggedIn: Bool = FirebaseManager.shared.auth.currentUser != nil
    @Published var recentMessageSender: String = ""
    @Published var recentMessageText: String = ""
    @Published var recentMessageTime: String = ""
    @Binding var isLogin: Bool
    
    init(isLogin: Binding<Bool>) {
        self._isLogin = isLogin
        self.configureNotification()
    }
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.fetchRecentMessage(_:)),
            name: .init(rawValue: "recentMessage"),
            object: nil
        )
    }
    
    @objc func fetchRecentMessage(_ notification: Notification) {
        guard let sender = notification.userInfo?["sender"] as? String,
              let text = notification.userInfo?["text"] as? String,
              let time = notification.userInfo?["time"] as? Date else { return }
        self.recentMessageSender = sender
        self.recentMessageText = text
        self.recentMessageTime = time.formattedTimeWithDate
    }
}

