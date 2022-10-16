////
////  SignUpView.swift
////  NC1
////
////  Created by Shin Jae Ung on 2022/04/25.
////
//
//import SwiftUI
//
//struct SignUpView1: View {
//    @Binding var showSignUpView: Bool
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var showAlert: Bool = false
//    @State private var doesSignUpSucceed: Bool = false
//
//    var body: some View {
//        VStack {
//            HStack {
//                TextField("Email", text: self.$email)
//                    .keyboardType(.emailAddress)
//                    .textInputAutocapitalization(.never)
//                Text("@pos.idserve.net")
//            }
//            .padding()
//            SecureField("Password, longer than 6 characters", text: self.$password)
//                .padding()
//            Button {
//                self.createNewAccount()
//            } label: {
//                Spacer()
//                Text("Sign in")
//                Spacer()
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.horizontal)
//        }
//        .alert(isPresented: self.$showAlert) {
//            Alert(
//                title: self.doesSignUpSucceed ? Text("성공") : Text("실패"),
//                message: self.doesSignUpSucceed ? Text("가입 성공!") : Text("가입 실패"),
//                dismissButton: .cancel() {
//                    self.showSignUpView = false
//                }
//            )
//        }
//        .navigationTitle("Register")
//    }
//
//    private func createNewAccount() {
//        let baseURL = "@pos.idserve.net"
//        FirebaseManager.shared.auth.createUser(withEmail: self.email + baseURL, password: self.password) { result, error in
//            guard error == nil else {
//                self.doesSignUpSucceed = false
//                self.showAlert = true
//                return
//            }
//            self.doesSignUpSucceed = true
//            self.showAlert = true
//            self.storeUserInformation()
//            self.sendEmailVerification()
//        }
//    }
//
//    private func sendEmailVerification() {
//        FirebaseManager.shared.auth.currentUser?.sendEmailVerification()
//    }
//
//    private func storeUserInformation() {
//        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
//        let displayNameChangeRequest = currentUser.createProfileChangeRequest()
//        let randomNumber = String(Int.random(in: 100..<999))
//        displayNameChangeRequest.displayName = "익명" + randomNumber
//        displayNameChangeRequest.commitChanges()
//        let userData = ["email": self.email, "uid": currentUser.uid, "displayName": "익명" + randomNumber]
//        FirebaseManager.shared.firestore.collection("users")
//            .document(currentUser.uid).setData(userData) { _ in }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView1(showSignUpView: .constant(true))
//    }
//}
