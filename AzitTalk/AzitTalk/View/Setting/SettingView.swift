//
//  SettingView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/27.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel: SettingViewModel
    @State private var isNicknameChanged: Bool = false
    
    init(isLogin: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: SettingViewModel(isLogin: isLogin))
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 75)
            VStack(spacing: 0) {
                InformationView(title: "사용자 정보")
                SettingNavigationLink(title: "닉네임", content: self.viewModel.nickName) {
                    NicknameChangeView(currentNickname: self.viewModel.nickName, isNicknameChanged: self.$isNicknameChanged)
                }
                SettingContentView(title: "이메일", content: self.viewModel.email)
                
                Spacer()
                    .frame(height: 49)
                
                InformationView(title: "앱 정보")
                SettingNavigationLink(title: "개발자 정보") {
                    DeveloperInformationView(
                        nickName: "Smile",
                        email: "struct.developer@gmail.com",
                        phoneNumber: "010-9769-9630"
                    )
                }
                SettingNavigationLink(title: "디자이너 정보") {
                    DeveloperInformationView(
                        nickName: "Maeve",
                        email: "mijchoi22@pos.idserve.net",
                        phoneNumber: ""
                    )
                }
                
                Spacer()
                
                Button(role: .destructive) {
                    self.viewModel.isLogoutButtonTouched = true
                } label: {
                    Text("로그아웃")
                }
                .padding()
                Button(role: .destructive) {
                    self.viewModel.isDeleteUserButtonTouched = true
                } label: {
                    Text("탈퇴하기")
                }
                .padding()
            }
            NavigationLink("DeleteUserView", isActive: self.$viewModel.isDeleteUserButtonTouched) {
                DeleteUserView(isLogin: self.$viewModel.isLogin)
            }
            .hidden()
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: self.isNicknameChanged) { newValue in
            if newValue {
                self.viewModel.updateNickname()
            }
        }
        .alert("로그아웃", isPresented: self.$viewModel.isLogoutButtonTouched, actions: {
            Button {
                Void()
            } label: {
                Text("취소")
            }
            Button {
                self.viewModel.signOut()
            } label: {
                Text("로그아웃")
            }
        }, message: {
            Text("다시 앱에 접속 후 로그인할 수 있습니다.")
        })
    }
}

fileprivate struct InformationView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

fileprivate struct SettingNavigationLink<Destination: View>: View {
    let title: String
    let content: String
    let destination: () -> Destination
    
    init(title: String, @ViewBuilder destination: @escaping () -> (Destination)) {
        self.title = title
        self.content = ""
        self.destination = destination
    }
    
    init(title: String, content: String, @ViewBuilder destination: @escaping () -> (Destination)) {
        self.title = title
        self.content = content
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            SettingContentView(title: title, content: content, isButton: true)
        }
    }
}

fileprivate struct SettingContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    var content: String = ""
    var isButton: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                HStack {
                    Text(title)
                        .fontWeight(.regular)
                    Spacer()
                }
                .padding(.leading, 16)
                .frame(width: self.content.isEmpty ? nil : 84)
                .multilineTextAlignment(.leading)
                if !content.isEmpty {
                    Text(content)
                }
                Spacer()
                if isButton {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.init(uiColor: .systemPink))
                        .padding(.horizontal, 23)
                }
            }
            .font(.body)
            .foregroundColor(.init(uiColor: .label))
            .padding(.vertical, 11)
            Divider()
                .overlay(colorScheme == .light ? .gray : .white)
            Spacer()
                .frame(height: 10)
        }
    }
}
