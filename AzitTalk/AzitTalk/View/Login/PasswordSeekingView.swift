//
//  PasswordSeekingView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

struct PasswordSeekingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PasswordSeekeingViewModel()
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
                                self.hideKeyboard()
                            }
                        Text("@pos.idserve.net")
                    }
                    Divider()
                        .overlay(colorScheme == .light ? .gray : .white)
                    Spacer()
                    AzitButton(
                        textColor: Color(uiColor: .label),
                        backgroundColor: Color(uiColor: .systemPink),
                        fill: true) {
                            Text("이메일 인증하기")
                        } onTap: {
                            self.hideKeyboard()
                            self.viewModel.sendPasswordReset()
                        }
                }
                .padding()
                .frame(height: geomerty.size.height)
            }
        }
        .navigationTitle("비밀번호 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.focusField = .email
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .alert(self.viewModel.isResetSent ? "인증하기" : "실패", isPresented: self.$viewModel.showAlert, actions: {
            Button {
                self.viewModel.isResetSent ? dismiss() : Void()
            } label: {
                Text("확인")
            }
        }, message: {
            Text(self.viewModel.errorMessage)
        })
    }
    
    private enum Field {
        case email
    }
}
