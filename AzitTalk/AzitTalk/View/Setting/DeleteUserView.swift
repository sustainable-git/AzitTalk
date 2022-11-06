//
//  DeleteUserView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/11/06.
//

import SwiftUI

struct DeleteUserView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DeleteUserViewModel
    @FocusState private var focusField: Field?
    
    init(isLogin: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: DeleteUserViewModel(isLogin: isLogin))
    }
    
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
                            Text("애지트톡 그만 이용하기")
                                .foregroundColor(.black)
                        } onTap: {
                            self.hideKeyboard()
                            self.viewModel.deleteUserButtonTouched()
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
        .alert("회원 탈퇴", isPresented: self.$viewModel.showAlert, actions: {
            Button {
                Void()
            } label: {
                Text("취소")
            }
            Button {
                self.viewModel.deleteConfirmButtonTouched()
            } label: {
                Text("탈퇴하기")
            }
        }, message: {
            Text("회원 정보를 삭제합니다.")
        })
        .alert("오류", isPresented: self.$viewModel.isErrorOccurred, actions: {
            Button {
                Void()
            } label: {
                Text("확인")
            }
        }, message: {
            Text("다시 시도하십시오.")
        })
    }
    
    private enum Field {
        case email
        case password
    }
}

