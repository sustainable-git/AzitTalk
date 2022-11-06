//
//  DeleteUserViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/11/06.
//

import SwiftUI

final class DeleteUserViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var isErrorOccurred: Bool = false
    @Binding var isLogin: Bool
    let baseURL = "@pos.idserve.net"
    var errorMessage: String = ""
    
    init(isLogin: Binding<Bool>) {
        self._isLogin = isLogin
    }
    
    func deleteUserButtonTouched() {
        self.showAlert = true
    }
    
    func deleteConfirmButtonTouched() {
        let credential = FirebaseManager.shared.credential(withEmail: self.email, password: self.password)
        guard let currentUser = FirebaseManager.shared.auth.currentUser else {
            try? FirebaseManager.shared.auth.signOut()
            return
        }
        
        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isErrorOccurred = true
                return
            }
            currentUser.delete { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isErrorOccurred = true
                }
                FirebaseManager.shared.firestore.collection("users")
                    .document(currentUser.uid).updateData(["fcmToken" : "deleted", "date": Date()])
                self.isLogin = false
            }
        }
    }
}
