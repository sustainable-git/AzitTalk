//
//  SplashViewModel.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

final class SplashViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet {
            if !isLoggedIn { onAppear() }
        }
    }
    @Published var isUnLoggedIn: Bool = false
    
    func onAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let currentUser = FirebaseManager.shared.auth.currentUser,
               currentUser.isEmailVerified {
                self?.isLoggedIn = true
            } else {
                self?.isUnLoggedIn = true
            }
        }
    }
}
