//
//  ChatRoomViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/22.
//

import SwiftUI
import Firebase
import MessageUI

final class ChatRoomViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var chatMessages: [ChatMessage] = []
    @Published var scrollToBottom = false
    @Published var scrollToLastPoint = false
    @Published var showLastUnreadMessage: Bool = false
    @Published var showFilteringAlert: Bool = false
    @Published var showMailView: Bool = false
    @Published var mailResult: Result<MFMailComposeResult, Error>? = nil
    @Published var refreshing = false {
        didSet {
            if oldValue == false && self.refreshing == true {
                self.loadMoreMessages()
            }
        }
    }
    @AppStorage("lastMessageNumber") var lastMessageNumber: Int = -1
    private var isUserOnChatRoom = false
    var currentShowingPastMessages = 10
    var lastTimeOnChatRoom: Date? {
        get { UserDefaults.standard.object(forKey: "lastTimeOnChatRoom") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastTimeOnChatRoom") }
    }
    var lastTimeOfReceivedMessage: Date? {
        get { UserDefaults.standard.object(forKey: "lastTimeOfReceivedMessage") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastTimeOfReceivedMessage") }
    }
    var numberOfUnreadMessages: Int {
        guard let lastTimeOnChatRoom = lastTimeOnChatRoom else { return 0 }
        return self.chatMessages.filter { $0.time > lastTimeOnChatRoom }.count
    }
    var blockedUsers: [String] {
        get { UserDefaults.standard.stringArray(forKey: "blockedUsers") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "blockedUsers") }
    }
    var isUserWatchingBottom: Bool = false {
        willSet {
            if newValue == true {
                self.showLastUnreadMessage = false
            }
        }
    }
    var selectedMessage: ChatMessage?
    var filteringWords: [String] = []
    
    init() {
        self.configureUserDefault()
        self.configureFilteringWords()
        self.fetchSavedMessages()
        self.addSnapshotListener()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewShouldScrollToBottom),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func viewShouldScrollToBottom() {
        self.scrollToBottom = true
    }
    
    @objc private func appWillTerminate() {
        if self.isUserOnChatRoom {
            self.lastTimeOnChatRoom = Date.now
        }
    }
    
    func isThisLastMessagePosition(after message: ChatMessage) -> Bool {
        guard let lastTimeOnChatRoom = lastTimeOnChatRoom else { return false }
        return message == self.chatMessages.last(where: { $0.time < lastTimeOnChatRoom })
    }
    
    func sendText() {
        guard !chatText.isEmpty else { return }
        guard !filteringWords.contains(chatText.lowercased()) else {
            self.showFilteringAlert = true
            chatText.removeAll()
            return
        }
        guard let sender = FirebaseManager.shared.auth.currentUser else { return }
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document("anonymous").collection("collection").document()
        let messageData: [String: Any] = ["senderEmail": sender.email ?? "error", "senderUID": sender.uid, "senderDisplayName": sender.displayName ?? "error", "text": self.chatText, "time": Date.now]
        document.setData(messageData)
        self.sendRecentMessageNotification(sender: sender.displayName ?? "error", text: self.chatText, time: Date.now)
        self.chatText.removeAll()
        self.viewShouldScrollToBottom()
    }
    
    func viewWillAppear() {
        self.isUserOnChatRoom = true
        self.scrollToLastPoint = true
    }
    
    func viewWillDisappear() {
        self.isUserOnChatRoom = false
        self.lastTimeOnChatRoom = Date.now
        objectWillChange.send()
    }
    
    func loadMoreMessages() {
        let messages = Caching.shared.fetchMessages(
            from: self.lastMessageNumber - (self.currentShowingPastMessages + 10),
            to: self.lastMessageNumber - (self.currentShowingPastMessages + 1)
        )
        self.chatMessages = messages + self.chatMessages
        self.currentShowingPastMessages += 10
        self.refreshing = false
    }
    
    func removeSelectedMessage() {
        guard let selectedMessage = selectedMessage,
              let removeIndex = self.chatMessages.firstIndex(of: selectedMessage) else { return }
        self.chatMessages.remove(at: removeIndex)
    }
    
    func blockUser() {
        guard let selectedMessage = selectedMessage else { return }
        self.blockedUsers.append(selectedMessage.senderUID)
    }
    
    func reportSelectedMessage() {
        guard let selectedMessage = selectedMessage,
              let reporter = FirebaseManager.shared.auth.currentUser else { return }
        let document = FirebaseManager.shared.firestore.collection("reports")
            .document("anonymous").collection("collection").document()
        let messageData: [String: Any] = ["reporterEmail": reporter.email ?? "error", "reporterUID": reporter.uid, "reportTime": Date.now, "senderUID": selectedMessage.senderUID, "senderDisplayName": selectedMessage.displayName, "text": selectedMessage.text, "sendTime": selectedMessage.time]
        document.setData(messageData)
        
        if MFMailComposeViewController.canSendMail() {
            self.showMailView = true
        }
    }
    
    private func configureUserDefault() {
        if UserDefaults.standard.object(forKey: "lastTimeOnChatRoom") as? Date == nil {
            self.lastTimeOnChatRoom = Date.now
        }
        if UserDefaults.standard.object(forKey: "lastTimeOfReceivedMessage") as? Date == nil {
            self.lastTimeOfReceivedMessage = Date.now
        }
    }
    
    private func configureFilteringWords() {
        guard let path = Bundle.main.path(forResource: "fword_list", ofType: "txt") else { return }
        self.filteringWords = try! String(contentsOfFile: path).split(separator: "\n").map { String($0) }
    }
    
    private func fetchSavedMessages() {
        if self.lastMessageNumber > 0 {
            self.chatMessages = Caching.shared.fetchMessages(from: self.lastMessageNumber - currentShowingPastMessages, to: self.lastMessageNumber)
            if let lastMessage = self.chatMessages.last {
                self.sendRecentMessageNotification(sender: lastMessage.displayName, text: lastMessage.text, time: lastMessage.time)
            }
        }
    }
    
    private func addSnapshotListener() {
        guard let lastTimeOfReceivedMessage = lastTimeOfReceivedMessage else { return }
        FirebaseManager.shared.firestore
            .collection("messages")
            .document("anonymous")
            .collection("collection")
            .whereField("time", isGreaterThan: lastTimeOfReceivedMessage)
            .order(by: "time", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil,
                      let snapshot = snapshot else { return }
                snapshot.documentChanges.forEach { [weak self] change in
                    guard let self = self else { return }
                    if change.type == .added {
                        let data = change.document.data()
                        guard let time = (data["time"] as? Timestamp)?.dateValue(),
                              time > lastTimeOfReceivedMessage else { return }
                        let message = ChatMessage(data: data)
                        guard !self.blockedUsers.contains(message.senderUID) else { return }
                        self.chatMessages.append(message)
                        self.lastMessageNumber += 1
                        Caching.shared.saveMessage(message, to: self.lastMessageNumber)
                    }
                }
                
                if let lastMessage = snapshot.documentChanges.filter({ [weak self] documentChange in
                    guard let self = self else { return false }
                    return !self.blockedUsers.contains(documentChange.document.data()["senderUID"] as? String ?? "")
                }).last, lastMessage.type == .added {
                    let data = lastMessage.document.data()
                    let sender = data["senderDisplayName"] as? String ?? "error"
                    let text = data["text"] as? String ?? ""
                    let time = (data["time"] as? Timestamp)?.dateValue() ?? Date()
                    self?.sendRecentMessageNotification(sender: sender ,text: text, time: time)
                    self?.lastTimeOfReceivedMessage = time
                    if let senderUID = data["senderUID"] as? String,
                       senderUID == FirebaseManager.shared.auth.currentUser?.uid {
                        self?.viewShouldScrollToBottom()
                        self?.showLastUnreadMessage = false
                    } else if let self = self, self.isUserWatchingBottom {
                        self.viewShouldScrollToBottom()
                        self.showLastUnreadMessage = false
                    } else {
                        self?.showLastUnreadMessage = true
                    }
                }
            }
    }
    
    private func sendRecentMessageNotification(sender: String, text: String, time: Date) {
        NotificationCenter.default.post(
            name: .init(rawValue: "recentMessage"),
            object: self,
            userInfo: ["sender": sender, "text": text, "time": time]
        )
    }
    
    func isThisShouldShowDate(before message: ChatMessage) -> Bool {
        guard let index = self.chatMessages.firstIndex(of: message) else { return false }
        guard index > 0 else { return true }
        let previousMessage = self.chatMessages[self.chatMessages.index(before: index)]
        
        return !Calendar.current.isDate(message.time, inSameDayAs: previousMessage.time)
    }
}
