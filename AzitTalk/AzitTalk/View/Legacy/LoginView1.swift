////
////  LoginView.swift
////  NC1
////
////  Created by Shin Jae Ung on 2022/04/25.
////
//
//import SwiftUI
//
//struct LoginView1: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var showAlert: Bool = false
//    @State private var showRegisterView: Bool = false
//    @State private var showNextView: Bool = false
//    @State private var errorMessage: String = ""
//    @State private var showPolicyView: Bool = false
//    private let baseURL: String = "@pos.idserve.net"
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Image("logo")
//                HStack {
//                    TextField("Email", text: self.$email)
//                        .keyboardType(.emailAddress)
//                        .textInputAutocapitalization(.never)
//                    Text("@pos.idserve.net")
//                }
//                .padding()
//                SecureField("Password", text: self.$password)
//                    .padding()
//                
//                Button {
//                    FirebaseManager.shared.auth.signIn(withEmail: self.email + baseURL, password: self.password) { result, error in
//                        if let error = error {
//                            self.errorMessage = error.localizedDescription
//                            self.showAlert = true
//                            return
//                        }
//                        guard let _ = result else {
//                            self.errorMessage = "No result"
//                            self.showAlert = true
//                            return
//                        }
//                        guard let currentUser = FirebaseManager.shared.auth.currentUser else {
//                            self.errorMessage = "Can't Find User"
//                            self.showAlert = true
//                            return
//                        }
//                        currentUser.reload()
//                        if currentUser.isEmailVerified {
//                            self.showPolicyView = true
//                        } else {
//                            self.errorMessage = "이메일 인증을 완료해주세요"
//                            self.showAlert = true
//                        }
//                    }
//                } label: {
//                    Spacer()
//                    Text("Log in")
//                    Spacer()
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.horizontal)
//                
//                NavigationLink(isActive: self.$showRegisterView) {
//                    SignUpView1(showSignUpView: self.$showRegisterView)
//                } label: {
//                    Spacer()
//                    Text("Register now")
//                        .font(.body)
//                    Spacer()
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.horizontal)
//                
//                Button {
//                    if !self.email.isEmpty {
//                        FirebaseManager.shared.auth.sendPasswordReset(withEmail: self.email + baseURL) { error in
//                            if let error = error {
//                                self.errorMessage = error.localizedDescription
//                                self.showAlert = true
//                            } else {
//                                self.errorMessage = "Please check your email"
//                                self.showAlert = true
//                            }
//                        }
//                    } else {
//                        self.errorMessage = "Type Email"
//                        self.showAlert = true
//                    }
//                } label: {
//                    Spacer()
//                    Text("Forget Password")
//                    Spacer()
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.horizontal)
//            }
//        }
//        .navigationTitle("Login")
//        .navigationViewStyle(.stack)
//        .alert(isPresented: self.$showAlert) {
//            Alert(title: Text(self.errorMessage), dismissButton: .cancel())
//        }
//        .popover(isPresented: self.$showPolicyView, content: {
//            PolicyNoticeView1(isButtonTapped: self.$showPolicyView) {
//                self.showPolicyView = false
//                self.showNextView = true
//            }
//        })
//        .fullScreenCover(isPresented: self.$showNextView) {
//            ChatListView1(showChatListView: self.$showNextView)
//        }
//        .onAppear {
//            if FirebaseManager.shared.auth.currentUser != nil, FirebaseManager.shared.auth.currentUser!.isEmailVerified {
//                self.showNextView = true
//            }
//        }
//    }
//}
//
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView1()
//        LoginView1()
//            .preferredColorScheme(.dark)
//    }
//}
