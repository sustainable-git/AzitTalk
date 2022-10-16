//
//  SignUpView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()
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
                    HStack {
                        Text("*6자 이상으로 입력하세요")
                        Spacer()
                    }
                    Spacer()
                    AzitButton(
                        textColor: Color(uiColor: .label),
                        backgroundColor: Color(uiColor: .systemPink),
                        fill: true) {
                            Text("이메일 인증하기")
                                .foregroundColor(.black)
                        } onTap: {
                            self.hideKeyboard()
                            self.viewModel.createNewAccount()
                        }
                }
                .padding()
                .frame(height: geomerty.size.height)
            }
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.focusField = .email
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .alert(self.viewModel.isSignUpSucceed ? "성공" : "실패", isPresented: self.$viewModel.showAlert, actions: {
            Button {
                self.viewModel.isSignUpSucceed ? self.dismiss() : Void()
            } label: {
                Text("확인")
            }
        }, message: {
            self.viewModel.isSignUpSucceed ? Text("메일함을 확인해주세요") : Text("다시 입력해주세요")
        })
    }
    
    private enum Field {
        case email
        case password
    }
}
