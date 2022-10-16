////
////  ChatListView.swift
////  NC1
////
////  Created by Shin Jae Ung on 2022/04/26.
////
//
//import SwiftUI
//import Combine
//
//class ChatListViewModel1: ObservableObject {
//    @Published var displayName: String = " "
//    @Published var isUserCurrentlyLoggedIn: Bool = FirebaseManager.shared.auth.currentUser != nil
//    @Published var recentMessage: String = ""
//    @Published var recentMessageTime: Date = Date()
//    
//    init() {
//        self.configureNotification()
//        self.fetchCurrentUser()
//    }
//    
//    private func configureNotification() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.fetchRecentMessage(_:)),
//            name: .init(rawValue: "recentMessage"),
//            object: nil
//        )
//    }
//    
//    @objc func fetchRecentMessage(_ notification: Notification) {
//        guard let text = notification.userInfo?["text"] as? String,
//              let time = notification.userInfo?["time"] as? Date else { return }
//        self.recentMessage = text
//        self.recentMessageTime = time
//    }
//    
//    private func fetchCurrentUser() {
//        guard let currentUser = FirebaseManager.shared.auth.currentUser else {
//            self.isUserCurrentlyLoggedIn = false
//            return
//        }
//        FirebaseManager.shared.firestore.collection("users")
//            .document(currentUser.uid)
//            .getDocument { document, error in
//                guard error == nil,
//                      let data = document?.data()
//                else {
//                    self.displayName = "Error"
//                    self.isUserCurrentlyLoggedIn = false
//                    return
//                }
//                self.displayName = data["displayName"] as? String ?? "Error"
//            }
//    }
//    
//    func signOut() {
//        try? FirebaseManager.shared.auth.signOut()
//        self.isUserCurrentlyLoggedIn = false
//    }
//    
//    func changeDisplayName(to name: String, result: (Bool) -> ()) {
//        guard name.count > 0 && !name.contains(" ") else {
//            result(false)
//            return
//        }
//        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
//        let displayNameChangeRequest = currentUser.createProfileChangeRequest()
//        displayNameChangeRequest.displayName = name
//        displayNameChangeRequest.commitChanges()
//        let userData = ["email": currentUser.email!, "uid": currentUser.uid, "displayName": name]
//        FirebaseManager.shared.firestore.collection("users")
//            .document(currentUser.uid).setData(userData) { _ in
//                self.fetchCurrentUser()
//            }
//        result(true)
//    }
//}
//
//struct ChatListView1: View {
//    @Binding var showChatListView: Bool
//    @StateObject private var viewModel = ChatListViewModel1()
//    @State private var showActionSheet = false
//    @State private var showNameChangingView = false
//    @State private var showInformationView = false
//    @State private var newDisplayName = ""
//    @State private var showNameChangingAlert = false
//    @StateObject private var chatRoomViewModel = ChatRoomViewModel1()
//    
//    init(showChatListView: Binding<Bool>) {
//        self._showChatListView = showChatListView
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                HStack(spacing: 20) {
//                    Image(systemName: "person.fill")
//                        .font(.title)
//                        .padding(.all, 10)
//                        .overlay(Circle().stroke())
//                        .clipShape(Circle())
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(self.viewModel.displayName)
//                            .font(.title)
//                            .fontWeight(.bold)
//                        HStack {
//                            Circle()
//                                .foregroundColor(.green)
//                                .frame(width: 14, height: 14)
//                            Text("online")
//                                .font(.callout)
//                                .foregroundColor(Color.init(uiColor: .lightGray))
//                        }
//                    }
//                    Spacer()
//                    Button {
//                        self.showActionSheet = true
//                    } label: {
//                        Image(systemName: "gear")
//                    }
//                    .confirmationDialog("Settings", isPresented: self.$showActionSheet) {
//                        Button("information") {
//                            self.showInformationView = true
//                        }
//                        Button("change name") {
//                            self.showNameChangingView = true
//                        }
//                        Button("sign out", role: .destructive) {
//                            self.viewModel.signOut()
//                        }
//                    }
//                }
//                .padding()
//                
//                ScrollView {
//                    VStack {
//                        NavigationLink {
//                            ChatRoomView1(viewModel: self.chatRoomViewModel)
//                        } label: {
//                            HStack(spacing: 20) {
//                                Image(systemName: "person.fill")
//                                    .font(.title)
//                                    .padding(.all, 5)
//                                    .overlay(Circle().stroke())
//                                    .clipShape(Circle())
//                                VStack(alignment: .leading, spacing: 0) {
//                                    HStack(alignment: .bottom) {
//                                        Text("익명 대화방")
//                                            .font(.body)
//                                        Spacer()
//                                        Text(self.viewModel.recentMessageTime.formattedTime)
//                                            .font(.caption2)
//                                    }
//                                    HStack {
//                                        Text(self.viewModel.recentMessage)
//                                            .font(.callout)
//                                            .lineLimit(2)
//                                            .multilineTextAlignment(.leading)
//                                            .foregroundColor(Color.init(uiColor: .lightGray))
//                                        Spacer()
//                                        if self.chatRoomViewModel.numberOfUnreadMessages > 0 {
//                                            ZStack {
//                                                RoundedRectangle(
//                                                    cornerRadius: UIFont.preferredFont(forTextStyle: .caption2).pointSize
//                                                )
//                                                .foregroundColor(.red)
//                                                Text("\(self.chatRoomViewModel.numberOfUnreadMessages)")
//                                                    .font(.caption2)
//                                                    .foregroundColor(.white)
//                                            }
//                                            .frame(
//                                                width: UIFont.preferredFont(forTextStyle: .caption2).pointSize * 2,
//                                                height: UIFont.preferredFont(forTextStyle: .caption2).pointSize
//                                            )
//                                        }
//                                    }
//                                }
//                            }
//                            .foregroundColor(Color(uiColor: .label))
//                        }
//                        Divider()
//                    }
//                    .padding(.horizontal)
//                }
//            }
//            .navigationTitle("채팅")
//            .navigationBarHidden(true)
//        }
//        .onChange(of: self.viewModel.isUserCurrentlyLoggedIn) { newValue in
//            self.showChatListView = newValue
//        }
//        .sheet(isPresented: self.$showNameChangingView) {
//            VStack {
//                TextField("Type new name within 8 characters", text: self.$newDisplayName)
//                    .onReceive(Just(self.newDisplayName)){ _ in
//                        if self.newDisplayName.count > 8 {
//                            self.newDisplayName = String(self.newDisplayName.prefix(8))
//                        }
//                    }
//                    .padding()
//                HStack {
//                    Button("Confirm") {
//                        self.viewModel.changeDisplayName(to: self.newDisplayName) { result in
//                            switch result {
//                            case true:
//                                self.newDisplayName.removeAll()
//                                self.showNameChangingView = false
//                            case false:
//                                self.showNameChangingAlert = true
//                            }
//                        }
//                    }
//                    .buttonStyle(.bordered)
//                    Button("Cancel", role: .cancel) {
//                        self.newDisplayName.removeAll()
//                        self.showNameChangingView = false
//                    }
//                    .buttonStyle(.bordered)
//                }
//            }
//            .alert("사용할 수 없는 이름", isPresented: self.$showNameChangingAlert) {
//                Button("Cancle") {
//                    Void()
//                }
//            } message: {
//                Text("\(newDisplayName)은 사용 불가능합니다.")
//            }
//        }
//        .sheet(isPresented: self.$showInformationView) {
//            VStack(alignment: .leading) {
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("Open Source License")
//                        .font(.title)
//                    
//                    VStack(alignment: .leading) {
//                        Text("CocoaPods")
//                            .fontWeight(.semibold)
//                        Text("\thttps://github.com/CocoaPods/CocoaPods")
//                            .font(.callout)
//                        Text("\tCopyright 2011 Eloy Duràn and Contributors")
//                            .font(.callout)
//                        Text("\tMIT License\n")
//                            .font(.callout)
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        Text("Firebase")
//                            .fontWeight(.semibold)
//                        Text("\thttps://github.com/firebase/")
//                            .font(.callout)
//                        Text("\tCopyright 2020 Google LLC")
//                            .font(.callout)
//                        Text("\tApache License 2.0\n")
//                            .font(.callout)
//                    }
//                }
//                
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("Developer")
//                        .font(.title)
//                    
//                    VStack(alignment: .leading) {
//                        Text("2022 Cohort, Smile")
//                            .fontWeight(.semibold)
//                        Text("\tEmail : struct.developer@gmail.com")
//                            .font(.callout)
//                        Text("\tPhone : 010-9769-9630")
//                            .font(.callout)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
