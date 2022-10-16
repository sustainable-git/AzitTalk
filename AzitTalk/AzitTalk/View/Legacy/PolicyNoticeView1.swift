////
////  PolicyNoticeView.swift
////  AzitTalk
////
////  Created by Shin Jae Ung on 2022/06/07.
////
//
//import SwiftUI
//
//struct PolicyNoticeView1: View {
//    @Binding var isButtonTapped: Bool
//    var completion: () -> ()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("공지")
//                .fontWeight(.semibold)
//            Text("AzitTalk에서 모니터링이나 신고를 통해 확인되는 모든 정책 위반에 대해서 강력한 제제를 부과합니다!\n(선정적이거나 광고성 글 또는 판매 글은 모두 영구 정지됩니다)\n\n아름다운 Azit 문화를 만들어 나가기 위해 멋진 Learner가 되어 주세요!")
//                .multilineTextAlignment(.leading)
//            HStack {
//                Spacer()
//                Button {
//                    self.isButtonTapped = true
//                    completion()
//                } label: {
//                    Text("알겠습니다")
//                }
//                .buttonStyle(.bordered)
//            }
//        }
//        .padding()
//    }
//}
