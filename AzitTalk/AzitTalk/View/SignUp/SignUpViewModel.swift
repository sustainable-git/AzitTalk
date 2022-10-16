//
//  SignUpViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

final class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var isSignUpSucceed: Bool = false
    let baseURL = "@pos.idserve.net"
    
    func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: self.email + baseURL, password: self.password) { result, error in
            guard error == nil else {
                self.isSignUpSucceed = false
                self.showAlert = true
                return
            }
            self.isSignUpSucceed = true
            self.showAlert = true
            self.storeUserInformation()
            self.sendEmailVerification()
        }
    }
    
    private func sendEmailVerification() {
        FirebaseManager.shared.auth.currentUser?.sendEmailVerification()
    }
    
    private func storeUserInformation() {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        let fcmToken = FirebaseManager.shared.fcmToken()
        let displayNameChangeRequest = currentUser.createProfileChangeRequest()
        let randomNumber = String(Int.random(in: 100..<999))
        displayNameChangeRequest.displayName = "익명" + randomNumber
        displayNameChangeRequest.commitChanges()
        let userData = ["email": self.email + baseURL, "uid": currentUser.uid, "displayName": "익명" + randomNumber, "fcmToken": fcmToken ?? "NoToken"]
        FirebaseManager.shared.firestore.collection("users")
            .document(currentUser.uid).setData(userData) { _ in }
    }
}
