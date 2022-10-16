////
////  ChatRoomView.swift
////  NC1
////
////  Created by Shin Jae Ung on 2022/04/26.
////
//
//import SwiftUI
//import Firebase
//import MessageUI
//
//class ChatRoomViewModel1: ObservableObject {
//    @Published var chatText = ""
//    @Published var chatMessages: [ChatMessage] = []
//    @Published var scrollToBottom = false
//    @Published var scrollToLastPoint = false
//    @Published var showLastUnreadMessage: Bool = false
//    @Published var showFilteringAlert: Bool = false
//    @Published var showMailView: Bool = false
//    @Published var mailResult: Result<MFMailComposeResult, Error>? = nil
//    @Published var refreshing = false {
//        didSet {
//            if oldValue == false && self.refreshing == true {
//                self.loadMoreMessages()
//            }
//        }
//    }
//    @AppStorage("lastMessageNumber") var lastMessageNumber: Int = -1
//    private var isUserOnChatRoom = false
//    var currentShowingPastMessages = 10
//    var lastTimeOnChatRoom: Date? {
//        get { UserDefaults.standard.object(forKey: "lastTimeOnChatRoom") as? Date }
//        set { UserDefaults.standard.set(newValue, forKey: "lastTimeOnChatRoom") }
//    }
//    var lastTimeOfReceivedMessage: Date? {
//        get { UserDefaults.standard.object(forKey: "lastTimeOfReceivedMessage") as? Date }
//        set { UserDefaults.standard.set(newValue, forKey: "lastTimeOfReceivedMessage") }
//    }
//    var numberOfUnreadMessages: Int {
//        guard let lastTimeOnChatRoom = lastTimeOnChatRoom else { return 0 }
//        return self.chatMessages.filter { $0.time > lastTimeOnChatRoom }.count
//    }
//    var blockedUsers: [String] {
//        get { UserDefaults.standard.stringArray(forKey: "blockedUsers") ?? [] }
//        set { UserDefaults.standard.set(newValue, forKey: "blockedUsers") }
//    }
//    var isUserWatchingBottom: Bool = false {
//        willSet {
//            if newValue == true {
//                self.showLastUnreadMessage = false
//            }
//        }
//    }
//    var selectedMessage: ChatMessage?
//    var filteringWords: [String] = []
//    
//    init() {
//        self.configureUserDefault()
//        self.configureFilteringWords()
//        self.fetchSavedMessages()
//        self.addSnapshotListener()
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.viewShouldScrollToBottom),
//            name: UIResponder.keyboardDidShowNotification,
//            object: nil
//        )
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.appWillTerminate),
//            name: UIApplication.willTerminateNotification,
//            object: nil
//        )
//    }
//    
//    @objc private func viewShouldScrollToBottom() {
//        self.scrollToBottom = true
//    }
//    
//    @objc private func appWillTerminate() {
//        if self.isUserOnChatRoom {
//            self.lastTimeOnChatRoom = Date.now
//        }
//    }
//    
//    func isThisLastMessagePosition(after message: ChatMessage) -> Bool {
//        guard let lastTimeOnChatRoom = lastTimeOnChatRoom else { return false }
//        return message == self.chatMessages.last(where: { $0.time < lastTimeOnChatRoom })
//    }
//    
//    func sendText() {
//        guard !chatText.isEmpty else { return }
//        guard !filteringWords.contains(chatText.lowercased()) else {
//            self.showFilteringAlert = true
//            chatText.removeAll()
//            return
//        }
//        guard let sender = FirebaseManager.shared.auth.currentUser else { return }
//        let document = FirebaseManager.shared.firestore.collection("messages")
//            .document("anonymous").collection("collection").document()
//        let messageData: [String: Any] = ["senderEmail": sender.email ?? "error", "senderUID": sender.uid, "senderDisplayName": sender.displayName ?? "error", "text": self.chatText, "time": Date.now]
//        document.setData(messageData)
//        self.sendRecentMessageNotification(text: self.chatText, time: Date.now)
//        self.chatText.removeAll()
//        self.viewShouldScrollToBottom()
//    }
//    
//    func viewWillAppear() {
//        self.isUserOnChatRoom = true
//        self.scrollToLastPoint = true
//    }
//    
//    func viewWillDisappear() {
//        self.isUserOnChatRoom = false
//        self.lastTimeOnChatRoom = Date.now
//        objectWillChange.send()
//    }
//    
//    func loadMoreMessages() {
//        let messages = Caching.shared.fetchMessages(
//            from: self.lastMessageNumber - (self.currentShowingPastMessages + 10),
//            to: self.lastMessageNumber - self.currentShowingPastMessages
//        )
//        self.chatMessages = messages + self.chatMessages
//        self.currentShowingPastMessages += 10
//        self.refreshing = false
//    }
//    
//    func removeSelectedMessage() {
//        guard let selectedMessage = selectedMessage,
//              let removeIndex = self.chatMessages.firstIndex(of: selectedMessage) else { return }
//        self.chatMessages.remove(at: removeIndex)
//    }
//    
//    func blockUser() {
//        guard let selectedMessage = selectedMessage else { return }
//        self.blockedUsers.append(selectedMessage.senderUID)
//    }
//    
//    func reportSelectedMessage() {
//        guard let selectedMessage = selectedMessage,
//              let reporter = FirebaseManager.shared.auth.currentUser else { return }
//        let document = FirebaseManager.shared.firestore.collection("reports")
//            .document("anonymous").collection("collection").document()
//        let messageData: [String: Any] = ["reporterEmail": reporter.email ?? "error", "reporterUID": reporter.uid, "reportTime": Date.now, "senderUID": selectedMessage.senderUID, "senderDisplayName": selectedMessage.displayName, "text": selectedMessage.text, "sendTime": selectedMessage.time]
//        document.setData(messageData)
//        
//        if MFMailComposeViewController.canSendMail() {
//            self.showMailView = true
//        }
//    }
//    
//    private func configureUserDefault() {
//        if UserDefaults.standard.object(forKey: "lastTimeOnChatRoom") as? Date == nil {
//            self.lastTimeOnChatRoom = Date.now
//        }
//        if UserDefaults.standard.object(forKey: "lastTimeOfReceivedMessage") as? Date == nil {
//            self.lastTimeOfReceivedMessage = Date.now
//        }
//    }
//    
//    private func configureFilteringWords() {
//        guard let path = Bundle.main.path(forResource: "fword_list", ofType: "txt") else { return }
//        self.filteringWords = try! String(contentsOfFile: path).split(separator: "\n").map { String($0) }
//    }
//    
//    private func fetchSavedMessages() {
//        if self.lastMessageNumber > 0 {
//            self.chatMessages = Caching.shared.fetchMessages(from: self.lastMessageNumber - currentShowingPastMessages, to: self.lastMessageNumber)
//            if let lastMessage = self.chatMessages.last {
//                self.sendRecentMessageNotification(text: lastMessage.text, time: lastMessage.time)
//            }
//        }
//    }
//    
//    private func addSnapshotListener() {
//        guard let lastTimeOfReceivedMessage = lastTimeOfReceivedMessage else { return }
//        FirebaseManager.shared.firestore
//            .collection("messages")
//            .document("anonymous")
//            .collection("collection")
//            .whereField("time", isGreaterThan: lastTimeOfReceivedMessage)
//            .order(by: "time", descending: false)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard error == nil,
//                      let snapshot = snapshot else { return }
//                snapshot.documentChanges.forEach { [weak self] change in
//                    guard let self = self else { return }
//                    if change.type == .added {
//                        let data = change.document.data()
//                        guard let time = (data["time"] as? Timestamp)?.dateValue(),
//                              time > lastTimeOfReceivedMessage else { return }
//                        let message = ChatMessage(data: data)
//                        guard !self.blockedUsers.contains(message.senderUID) else { return }
//                        self.chatMessages.append(message)
//                        self.lastMessageNumber += 1
//                        Caching.shared.saveMessage(message, to: self.lastMessageNumber)
//                    }
//                }
//                
//                if let lastMessage = snapshot.documentChanges.filter({ [weak self] documentChange in
//                    guard let self = self else { return false }
//                    return !self.blockedUsers.contains(documentChange.document.data()["senderUID"] as? String ?? "")
//                }).last, lastMessage.type == .added {
//                    let data = lastMessage.document.data()
//                    let text = data["text"] as? String ?? ""
//                    let time = (data["time"] as? Timestamp)?.dateValue() ?? Date()
//                    self?.sendRecentMessageNotification(text: text, time: time)
//                    self?.lastTimeOfReceivedMessage = time
//                    if let senderUID = data["senderUID"] as? String,
//                       senderUID == FirebaseManager.shared.auth.currentUser?.uid {
//                        self?.viewShouldScrollToBottom()
//                        self?.showLastUnreadMessage = false
//                    } else if let self = self, self.isUserWatchingBottom {
//                        self.viewShouldScrollToBottom()
//                        self.showLastUnreadMessage = false
//                    } else {
//                        self?.showLastUnreadMessage = true
//                    }
//                }
//            }
//    }
//    
//    private func sendRecentMessageNotification(text: String, time: Date) {
//        NotificationCenter.default.post(
//            name: .init(rawValue: "recentMessage"),
//            object: self,
//            userInfo: ["text": text, "time": time]
//        )
//    }
//}
//
//struct ChatRoomView1: View {
//    @ObservedObject private var viewModel: ChatRoomViewModel1
//    @State private var isTextFieldTouched: Bool = false
//    @State private var scrollViewHeight: CGFloat = .zero
//    @State private var wholeViewHeight: CGFloat = .zero
//    @State private var showDeleteAlert: Bool = false
//    @State private var showReportAlert: Bool = false
//    @State private var showBlockAlert: Bool = false
//    private let spaceName = "ChatRoomView"
//    
//    init(viewModel: ChatRoomViewModel1) {
//        self.viewModel = viewModel
//        let appearence = UINavigationBarAppearance()
//        appearence.configureWithTransparentBackground()
//        UINavigationBar.appearance().standardAppearance = appearence
//        UINavigationBar.appearance().scrollEdgeAppearance = appearence
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            ZStack {
//                RefreshableScrollView(refreshing: self.$viewModel.refreshing) {
//                    ScrollViewReader { proxy in
//                        Text("부적절하거나 불쾌감을 줄 수 있는 대화는 회원제제를 받을 수 있습니다.")
//                            .lineLimit(.none)
//                            .multilineTextAlignment(.center)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 5)
//                                    .stroke()
//                            )
//                            .padding()
//                        
//                        ForEach(self.viewModel.chatMessages) { message in
//                            MessageView(message: message)
//                                .contextMenu {
//                                    Button(role: .cancel) {
//                                        self.showDeleteAlert = true
//                                        self.viewModel.selectedMessage = message
//                                    } label: {
//                                        Text("삭제")
//                                    }
//                                    Button(role: .destructive) {
//                                        self.showBlockAlert = true
//                                        self.viewModel.selectedMessage = message
//                                    } label: {
//                                        Text("차단")
//                                    }
//                                    Button(role: .destructive) {
//                                        self.showReportAlert = true
//                                        self.viewModel.selectedMessage = message
//                                    } label: {
//                                        Text("사용자 신고")
//                                    }
//                                }
//                            if self.viewModel.isThisLastMessagePosition(after: message) {
//                                Text("여기까지 읽으셨습니다.")
//                                    .id("lastPoint")
//                                    .padding(.horizontal)
//                                    .padding(.vertical, 5)
//                                    .background(
//                                        Capsule(style: .continuous)
//                                            .opacity(0.1)
//                                    )
//                                    .padding(.bottom, 5)
//                                    .onReceive(self.viewModel.$scrollToLastPoint) { output in
//                                        if output {
//                                            DispatchQueue.main.async {
//                                                withAnimation(.easeIn(duration: 0.5)) {
//                                                    proxy.scrollTo("lastPoint", anchor: .center)
//                                                }
//                                            }
//                                            self.viewModel.scrollToLastPoint = false
//                                        }
//                                    }
//                            }
//                        }
//                        
//                        HStack{ Spacer() }
//                            .id("empty")
//                            .frame(width: 0, height: 0)
//                            .onReceive(self.viewModel.$scrollToBottom) { output in
//                                if output {
//                                    DispatchQueue.main.async {
//                                        withAnimation(.easeIn(duration: 0.5)) {
//                                            proxy.scrollTo("empty", anchor: .bottom)
//                                        }
//                                    }
//                                    self.viewModel.scrollToBottom = false
//                                }
//                            }
//                    }
//                    .background(
//                        GeometryReader { proxy in
//                            Color.clear.preference(
//                                key: ViewOffsetKey.self,
//                                value: -1 * proxy.frame(in: .named(spaceName)).origin.y
//                            )
//                        }
//                    )
//                    .background(
//                        GeometryReader { proxy in
//                            Color.clear.preference(
//                                key: ViewHeightKey.self,
//                                value: proxy.size.height
//                            )
//                        }
//                    )
//                    .onPreferenceChange(ViewHeightKey.self) { value in
//                        self.scrollViewHeight = value
//                    }
//                    .onPreferenceChange(ViewOffsetKey.self) { value in
//                        if value + 100 >= self.scrollViewHeight - self.wholeViewHeight ||
//                            self.scrollViewHeight < self.wholeViewHeight {
//                            self.viewModel.isUserWatchingBottom = true
//                        } else {
//                            self.viewModel.isUserWatchingBottom = false
//                        }
//                    }
//                }
//                .onTapGesture {
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }
//                .background(
//                    GeometryReader { proxy in
//                        Color.clear.preference(
//                            key: ViewHeightKey.self,
//                            value: proxy.size.height
//                        )
//                    }
//                )
//                .onPreferenceChange(ViewHeightKey.self) { value in
//                    self.wholeViewHeight = value
//                }
//                
//                VStack {
//                    Spacer()
//                    Button {
//                        self.viewModel.scrollToBottom = true
//                        self.viewModel.showLastUnreadMessage = false
//                    } label: {
//                        HStack {
//                            Text(self.viewModel.chatMessages.last?.text ?? "")
//                                .padding(5)
//                                .lineLimit(1)
//                                .foregroundColor(.init(uiColor: .label))
//                            Spacer()
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.init(uiColor: .systemBackground))
//                    .padding(5)
//                }
//                .opacity(self.viewModel.showLastUnreadMessage ? 1 : 0)
//            }
//            
//            VStack(spacing: 0) {
//                HStack {
//                    TextEditor(text: self.$viewModel.chatText)
//                        .frame(maxHeight: UIFont.preferredFont(forTextStyle: .body).pointSize * 2.5)
//                        .font(.body)
//                        .multilineTextAlignment(.leading)
//                        .padding(.all, 5)
//                        .padding(.horizontal, 5)
//                        .overlay(Capsule().stroke())
//                    Button {
//                        self.viewModel.sendText()
//                    } label: {
//                        Text("전송")
//                            .padding(.all, 8)
//                            .padding(.horizontal)
//                            .foregroundColor(.white)
//                            .background(.blue)
//                            .cornerRadius(8)
//                    }
//                }
//            }
//            .padding(.vertical, 8)
//            .padding(.horizontal)
//            .background(Color(uiColor: .systemBackground))
//        }
//        .navigationTitle("익명 대화방")
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color(uiColor: .systemGray5))
//        .onAppear {
//            self.viewModel.viewWillAppear()
//        }
//        .onDisappear {
//            self.viewModel.viewWillDisappear()
//        }
//        .alert("나에게서만 삭제", isPresented: self.$showDeleteAlert, actions: {
//            Button(role: .cancel) {
//                Void()
//            } label: {
//                Text("취소")
//            }
//            Button(role: .none) {
//                self.viewModel.removeSelectedMessage()
//            } label: {
//                Text("삭제")
//            }
//        }, message: {
//            Text("삭제된 메시지는 내 체팅방에서만 적용됩니다.")
//        })
//        .alert("사용자 차단", isPresented: self.$showBlockAlert, actions: {
//            Button(role: .cancel) {
//                Void()
//            } label: {
//                Text("취소")
//            }
//            Button(role: .destructive) {
//                self.viewModel.blockUser()
//            } label: {
//                Text("차단")
//            }
//        }, message: {
//            Text("해당 사용자를 영구적으로 차단합니다.")
//        })
//        .alert("신고하기", isPresented: self.$showReportAlert, actions: {
//            Button(role: .cancel) {
//                Void()
//            } label: {
//                Text("취소")
//            }
//            Button(role: .destructive) {
//                self.viewModel.reportSelectedMessage()
//            } label: {
//                Text("신고")
//            }
//        }, message: {
//            Text("해당 메시지를 불쾌감을 주는 콘텐츠로 신고합니다.")
//        })
//        .alert("전송 실패", isPresented: self.$viewModel.showFilteringAlert, actions: {
//            Button {
//                Void()
//            } label: {
//                Text("확인")
//            }
//        }, message: {
//            Text("타인에게 불쾌감을 줄 수 있는 내용은 삼가 부탁드립니다.")
//        })
//        .sheet(isPresented: self.$viewModel.showMailView) {
//            MailView(result: self.$viewModel.mailResult)
//        }
//    }
//}
//
//struct ViewHeightKey: PreferenceKey {
//    typealias Value = CGFloat
//    static var defaultValue: Value = .zero
//    static func reduce(value _: inout Value, nextValue: () -> Value) {
//        _ = nextValue()
//    }
//}
//
//struct ViewOffsetKey: PreferenceKey {
//    typealias Value = CGFloat
//    static var defaultValue: Value = .zero
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value += nextValue()
//    }
//}
