//
//  LoginViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoginSucceed: Bool = false
    @Published var isPolicyAgreed: Bool = false
    @Published var errorMessage: String = ""
    
    func login() {
        let baseURL = "@pos.idserve.net"
        FirebaseManager.shared.auth.signIn(withEmail: self.email + baseURL, password: self.password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                return
            }
            guard let _ = result else {
                self.errorMessage = "No result"
                self.showAlert = true
                return
            }
            guard let currentUser = FirebaseManager.shared.auth.currentUser else {
                self.errorMessage = "등록되지 않은 아이디입니다"
                self.showAlert = true
                return
            }
            currentUser.reload()
            if currentUser.isEmailVerified {
                self.isLoginSucceed = true
                let fcmToken = FirebaseManager.shared.fcmToken()
                FirebaseManager.shared.firestore.collection("users")
                    .document(currentUser.uid).updateData(["fcmToken" : fcmToken ?? "NoToken"])
                self.email.removeAll()
                self.password.removeAll()
            } else {
                self.errorMessage = "이메일 인증을 완료해주세요"
                self.showAlert = true
            }
        }
    }
    
    func policyAgree() {
        self.isLoginSucceed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
            self.isPolicyAgreed = true
        }
    }
}
