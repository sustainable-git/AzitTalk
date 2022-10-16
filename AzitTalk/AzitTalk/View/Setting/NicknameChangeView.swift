//
//  NicknameChangeView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/10/03.
//

import SwiftUI

struct NicknameChangeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Binding private var isNicknameChanged: Bool
    @State private var nickName: String = ""
    @State private var isNicknameChangeFailed: Bool = false
    private let currentNickname: String
    
    init(currentNickname: String, isNicknameChanged: Binding<Bool>) {
        self.currentNickname = currentNickname
        self._isNicknameChanged = isNicknameChanged
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                TextField(currentNickname, text: self.$nickName)
                Spacer()
            }
            Divider()
                .overlay(colorScheme == .light ? .gray : .white)
            HStack {
                Spacer()
                Text("\(self.nickName.isEmpty ? currentNickname.count : self.nickName.count)/10")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("닉네임 설정")
        .toolbar{
            ToolbarItem {
                Button("완료") {
                    changeDisplayName(to: self.nickName) { isSucceed in
                        switch isSucceed {
                        case true:
                            self.isNicknameChanged = true
                            dismiss()
                        case false:
                            self.isNicknameChangeFailed = true
                        }
                    }
                }
            }
        }
        .alert("사용할 수 없는 이름", isPresented: self.$isNicknameChangeFailed) {
            Button("취소") { Void() }
        } message: {
            Text("\(nickName)은 사용 불가능합니다.")
        }
    }
    
    func changeDisplayName(to name: String, result: @escaping (Bool) -> ()) {
        guard 1...10 ~= name.count && !name.contains(" ") else {
            result(false)
            return
        }
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        let displayNameChangeRequest = currentUser.createProfileChangeRequest()
        displayNameChangeRequest.displayName = name
        displayNameChangeRequest.commitChanges { error in
            guard error == nil else { return }
            let userData = ["displayName": name]
            FirebaseManager.shared.firestore.collection("users")
                .document(currentUser.uid).updateData(userData) { error in
                    if let _ = error {
                        result(false)
                    } else {
                        result(true)
                    }
                }
        }
    }
}
