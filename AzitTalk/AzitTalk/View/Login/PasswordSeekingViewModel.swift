//
//  PasswordSeekingViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

final class PasswordSeekeingViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var showAlert: Bool = false
    @Published var isResetSent: Bool = false
    @Published var errorMessage: String = ""
    
    func sendPasswordReset() {
        let baseURL = "@pos.idserve.net"
        if !self.email.isEmpty {
            FirebaseManager.shared.auth.sendPasswordReset(withEmail: self.email + baseURL) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                } else {
                    self.errorMessage = "메일함을 확인해주세요"
                    self.isResetSent = true
                    self.showAlert = true
                }
            }
        } else {
            self.errorMessage = "이메일을 입력해주세요."
            self.showAlert = true
        }
    }
}
