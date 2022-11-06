//
//  FirebaseManager.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/07/16.
//

import SwiftUI
import Firebase
import FirebaseMessaging

final class FirebaseManager: NSObject {
    @AppStorage("email") var email: String = ""
    static let shared = FirebaseManager()
    let auth: Auth
    let firestore: Firestore
    
    private override init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        super.init()
    }
    
    func fcmToken() -> String? {
        return Messaging.messaging().fcmToken
    }
    
    func credential(withEmail email: String, password: String) -> AuthCredential {
        let baseURL = "@pos.idserve.net"
        return EmailAuthProvider.credential(withEmail: email + baseURL, password: password)
    }
}
