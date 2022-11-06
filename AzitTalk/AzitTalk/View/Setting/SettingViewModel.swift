//
//  SettingViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/10/03.
//

import SwiftUI

final class SettingViewModel: ObservableObject {
    @Binding var isLogin: Bool
    @Published var nickName: String = ""
    @Published var isLogoutButtonTouched: Bool = false
    @Published var isDeleteUserButtonTouched: Bool = false
    var email: String = ""
    
    init(isLogin: Binding<Bool>) {
        self._isLogin = isLogin
        let sender = FirebaseManager.shared.auth.currentUser
        self.nickName = sender?.displayName ?? "error"
        self.email = sender?.email ?? "error"
    }
    
    func signOut() {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        try? FirebaseManager.shared.auth.signOut()
        FirebaseManager.shared.firestore.collection("users")
            .document(currentUser.uid).updateData(["fcmToken" : "logOut"])
        self.isLogin = false
    }
    
    func updateNickname() {
        guard let currentUser = FirebaseManager.shared.auth.currentUser,
              let displayName = currentUser.displayName else { return }
        self.nickName = displayName
    }
}

