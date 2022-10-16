//
//  ChatRoomView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/22.
//

import SwiftUI

struct ChatRoomView: View {
    @ObservedObject private var viewModel: ChatRoomViewModel
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var wholeViewHeight: CGFloat = .zero
    @State private var showDeleteAlert: Bool = false
    @State private var showReportAlert: Bool = false
    @State private var showBlockAlert: Bool = false
    private let spaceName = "ChatRoomView"
    
    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Rectangle()
                    .frame(height: 0)
                    .background(Color.init(uiColor:.systemBackground))
                ZStack {
                    RefreshableScrollView(refreshing: self.$viewModel.refreshing) {
                        ScrollViewReader { proxy in
                            Text("부적절하거나 불쾌감을 줄 수 있는 대화는 회원제제를 받을 수 있습니다.")
                                .lineLimit(.none)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke()
                                )
                                .padding()
                            
                            ForEach(self.viewModel.chatMessages) { message in
                                if self.viewModel.isThisShouldShowDate(before: message) {
                                    Text(message.time.formattedDate)
                                        .fontWeight(.semibold)
                                        .font(.footnote)
                                        .padding(.vertical, 20)
                                }
                                MessageView(message: message)
                                    .contextMenu {
                                        Button(role: .cancel) {
                                            self.showDeleteAlert = true
                                            self.viewModel.selectedMessage = message
                                        } label: {
                                            Text("삭제")
                                        }
                                        Button(role: .destructive) {
                                            self.showBlockAlert = true
                                            self.viewModel.selectedMessage = message
                                        } label: {
                                            Text("차단")
                                        }
                                        Button(role: .destructive) {
                                            self.showReportAlert = true
                                            self.viewModel.selectedMessage = message
                                        } label: {
                                            Text("사용자 신고")
                                        }
                                    }
                                if self.viewModel.isThisLastMessagePosition(after: message) {
                                    Text("여기까지 읽었어요")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .id("lastPoint")
                                        .padding(.horizontal, 50)
                                        .padding(.vertical, 10)
                                        .background(Capsule().opacity(0.1))
                                        .padding(.bottom, 5)
                                        .onReceive(self.viewModel.$scrollToLastPoint) { output in
                                            if output {
                                                DispatchQueue.main.async {
                                                    withAnimation(.easeIn(duration: 0.5)) {
                                                        proxy.scrollTo("lastPoint", anchor: .center)
                                                    }
                                                }
                                                self.viewModel.scrollToLastPoint = false
                                            }
                                        }
                                }
                            }
                            
                            HStack{ Spacer() }
                                .id("empty")
                                .frame(width: 0, height: 0)
                                .onReceive(self.viewModel.$scrollToBottom) { output in
                                    if output {
                                        DispatchQueue.main.async {
                                            withAnimation(.easeIn(duration: 0.5)) {
                                                proxy.scrollTo("empty", anchor: .bottom)
                                            }
                                        }
                                        self.viewModel.scrollToBottom = false
                                    }
                                }
                        }
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ViewOffsetKey.self,
                                    value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                                )
                            }
                        )
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ViewHeightKey.self,
                                    value: proxy.size.height
                                )
                            }
                        )
                        .onPreferenceChange(ViewHeightKey.self) { value in
                            self.scrollViewHeight = value
                        }
                        .onPreferenceChange(ViewOffsetKey.self) { value in
                            if value + 100 >= self.scrollViewHeight - self.wholeViewHeight ||
                                self.scrollViewHeight < self.wholeViewHeight {
                                self.viewModel.isUserWatchingBottom = true
                            } else {
                                self.viewModel.isUserWatchingBottom = false
                            }
                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ViewHeightKey.self,
                                value: proxy.size.height
                            )
                        }
                    )
                    .onPreferenceChange(ViewHeightKey.self) { value in
                        self.wholeViewHeight = value
                    }
                    
                    VStack {
                        Spacer()
                        Button {
                            self.viewModel.scrollToBottom = true
                            self.viewModel.showLastUnreadMessage = false
                        } label: {
                            HStack {
                                Text(self.viewModel.chatMessages.last?.text ?? "")
                                    .padding(5)
                                    .lineLimit(1)
                                    .foregroundColor(.init(uiColor: .label))
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.init(uiColor: .systemBackground))
                        .padding(5)
                    }
                    .opacity(self.viewModel.showLastUnreadMessage ? 1 : 0)
                }
            }
            
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    TextEditorView(string: self.$viewModel.chatText)
                    Button {
                        self.viewModel.sendText()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .padding(.all, 5)
                            .foregroundColor(.init(uiColor: .systemPink))
                            .opacity(self.viewModel.chatText.isEmpty ? 0.5 : 1)
                    }
                }
                .overlay(
                    RoundedRectangle(
                        cornerRadius: UIFont.preferredFont(forTextStyle: .body).pointSize + 4
                    )
                    .stroke().foregroundColor(.init(uiColor: .systemGray3)))
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("Azit Talk")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            self.viewModel.viewWillAppear()
        }
        .onDisappear {
            self.viewModel.viewWillDisappear()
        }
        .alert("나에게서만 삭제", isPresented: self.$showDeleteAlert, actions: {
            Button(role: .cancel) {
                Void()
            } label: {
                Text("취소")
            }
            Button(role: .none) {
                self.viewModel.removeSelectedMessage()
            } label: {
                Text("삭제")
            }
        }, message: {
            Text("삭제된 메시지는 내 체팅방에서만 적용됩니다.")
        })
        .alert("사용자 차단", isPresented: self.$showBlockAlert, actions: {
            Button(role: .cancel) {
                Void()
            } label: {
                Text("취소")
            }
            Button(role: .destructive) {
                self.viewModel.blockUser()
            } label: {
                Text("차단")
            }
        }, message: {
            Text("해당 사용자를 영구적으로 차단합니다.")
        })
        .alert("신고하기", isPresented: self.$showReportAlert, actions: {
            Button(role: .cancel) {
                Void()
            } label: {
                Text("취소")
            }
            Button(role: .destructive) {
                self.viewModel.reportSelectedMessage()
            } label: {
                Text("신고")
            }
        }, message: {
            Text("해당 메시지를 불쾌감을 주는 콘텐츠로 신고합니다.")
        })
        .alert("전송 실패", isPresented: self.$viewModel.showFilteringAlert, actions: {
            Button {
                Void()
            } label: {
                Text("확인")
            }
        }, message: {
            Text("타인에게 불쾌감을 줄 수 있는 내용은 삼가 부탁드립니다.")
        })
        .sheet(isPresented: self.$viewModel.showMailView) {
            MailView(result: self.$viewModel.mailResult)
        }
    }
}

fileprivate struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = .zero
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
fileprivate struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
