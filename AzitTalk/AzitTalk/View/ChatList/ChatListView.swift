//
//  ChatListView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

struct ChatListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: ChatListViewModel
    @StateObject private var chatRoomViewModel = ChatRoomViewModel()
    
    init(isLogin: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: ChatListViewModel(isLogin: isLogin))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Spacer()
                        .frame(height: 25)
                    HStack {
                        Text("채팅")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            Void()
                        } label: {
                            NavigationLink {
                                SettingView(isLogin: self.$viewModel.isLogin)
                            } label: {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.init(uiColor: .systemPink))
                                    .font(.title2)
                            }
                        }
                    }
                }
                .padding(.all, 25)
                
                Divider()
                    .overlay(colorScheme == .light ? .gray : .white)
                    .padding(.leading, 25)
                
                ScrollView {
                    NavigationLink {
                        ChatRoomView(viewModel: chatRoomViewModel)
                    } label: {
                        ChatRoomOverviewView(
                            isNewMessageArrived: self.chatRoomViewModel.numberOfUnreadMessages > 0,
                            displaySender: self.viewModel.recentMessageSender,
                            displayTime: self.viewModel.recentMessageTime,
                            displayMessage: self.viewModel.recentMessageText
                        )
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .accentColor(.init(uiColor: .label))
    }
}

fileprivate struct ChatRoomOverviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    let isNewMessageArrived: Bool
    let displaySender: String
    let displayTime: String
    let displayMessage: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 5)
            HStack(spacing: 0) {
                Circle()
                    .opacity(self.isNewMessageArrived ? 1 : 0)
                    .frame(width: 10, height: 10)
                    .foregroundColor(.init(uiColor: .systemPink))
                    .padding(.horizontal, 7.5)
                Text("Cohort 2022")
                    .foregroundColor(.init(uiColor: .label))
                    .fontWeight(.semibold)
                Spacer()
                Text(displayTime)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            HStack(alignment: .top) {
                Text(displaySender + " : " + displayMessage)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 25)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
            }
            .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize * 3)
            Spacer()
                .frame(height: 5)
            Divider()
                .overlay(colorScheme == .light ? .gray : .white)
                .padding(.leading, 25)
        }
    }
}
