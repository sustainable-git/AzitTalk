//
//  EntranceView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/08/27.
//

import SwiftUI

struct EntranceView: View {
    @State private var isSignupTouched: Bool = false
    @State private var isLoginTouched: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .frame(height: Constant.screenHeight * 0.15)
                HStack {
                    Text("애지트에서\n익명으로 오고가는\n모든 이야기")
                        .font(.system(size: 34))
                        .fontWeight(.bold)
                    Spacer()
                }
                Spacer()
                            
                NavigationLink(isActive: self.$isSignupTouched) {
                    SignUpView()
                } label: {
                    EmptyView()
                }
                
                NavigationLink(isActive: self.$isLoginTouched) {
                    LoginView()
                } label: {
                    EmptyView()
                }
                
                AzitButton(
                    textColor: Color(uiColor: .label),
                    backgroundColor: Color(uiColor: .systemPink),
                    fill: true) {
                        Text("애지트톡에 처음 참여해요")
                            .foregroundColor(.black)
                    } onTap: {
                        self.isSignupTouched = true
                    }
                AzitButton(
                    textColor: Color(uiColor: .label),
                    backgroundColor: Color(uiColor: .systemPink),
                    fill: false) {
                        Text("애지트톡에 다시 돌아왔어요")
                    } onTap: {
                        self.isLoginTouched = true
                    }
            }
            .navigationTitle("")
            .padding(28)
        }
        .navigationViewStyle(.stack)
        .accentColor(.init(uiColor: .label))
    }
}

struct AzitButton<Content: View>: View {
    let content: () -> Content
    let onTap: () -> ()
    let textColor: Color
    let backgroundColor: Color
    let fill: Bool
    
    init(textColor: Color, backgroundColor: Color, fill: Bool, @ViewBuilder content: @escaping () -> Content, onTap: @escaping () -> ()) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.fill = fill
        self.content = content
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Spacer()
                self.content()
                    .foregroundColor(self.textColor)
                    .padding(.vertical)
                Spacer()
            }
            .background(
                ZStack {
                    switch self.fill {
                    case true:
                        Capsule()
                            .foregroundColor(self.backgroundColor)
                    case false:
                        Capsule()
                            .stroke()
                            .foregroundColor(self.backgroundColor)
                    }
                }
            )
        }
//        HStack {
//            Spacer()
//            self.content()
//                .foregroundColor(self.textColor)
//                .padding(.vertical)
//            Spacer()
//        }
//        .background(
//            ZStack {
//                switch self.fill {
//                case true:
//                    Capsule()
//                        .foregroundColor(self.backgroundColor)
//                case false:
//                    Capsule()
//                        .stroke()
//                        .foregroundColor(self.backgroundColor)
//                }
//            }
//        )
//        .onTapGesture {
//            onTap()
//        }
    }
}
