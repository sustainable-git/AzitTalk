//
//  LoginView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusField: Field?
    
    var body: some View {
        GeometryReader { geomerty in
            ScrollView {
                VStack {
                    Spacer()
                    HStack {
                        TextField("pos 아이디를 입력하세요", text: self.$viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .focused($focusField, equals: .email)
                            .onSubmit {
                                self.focusField = .password
                            }
                        Text("@pos.idserve.net")
                    }
                    Divider()
                        .overlay(colorScheme == .light ? .gray : .white)
                    Spacer()
                        .frame(height: 36.5)
                    SecureField("비밀번호를 입력하세요", text: self.$viewModel.password)
                        .focused($focusField, equals: .password)
                        .onSubmit {
                            self.hideKeyboard()
                        }
                    Divider()
                        .overlay(colorScheme == .light ? .gray : .white)
                    Spacer()
                        .frame(height: 36.5)
                    HStack {
                        Spacer()
                        NavigationLink {
                            PasswordSeekingView()
                        } label: {
                            VStack {
                                Text("비밀번호를 잊어버렸어요")
                                    .foregroundColor(colorScheme == .light ? .gray : .white)
                                    .fontWeight(.light)
                                    .font(.footnote)
                                    .underline(true, color: colorScheme == .light ? .gray : .white)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                    AzitButton(
                        textColor: Color(uiColor: .label),
                        backgroundColor: Color(uiColor: .systemPink),
                        fill: true) {
                            Text("대화에 참여하기")
                                .foregroundColor(.black)
                        } onTap: {
                            self.hideKeyboard()
                            self.viewModel.login()
                        }
                }
                .padding()
                .frame(height: geomerty.size.height)
            }
        }
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.focusField = .email
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .alert("로그인 실패", isPresented: self.$viewModel.showAlert, actions: {
            Button {
                Void()
            } label: {
                Text("확인")
            }
        }, message: {
            Text(self.viewModel.errorMessage)
        })
        .fullScreenCover(isPresented: self.$viewModel.isLoginSucceed) {
            PolicyNoticeView() {
                self.viewModel.policyAgree()
            }
        }
        .fullScreenCover(isPresented: self.$viewModel.isPolicyAgreed) {
            ChatListView(isLogin: self.$viewModel.isPolicyAgreed)
        }
    }
    
    private enum Field {
        case email
        case password
    }
}
