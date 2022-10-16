//
//  PolicyNoticeView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/09/21.
//

import SwiftUI

struct PolicyNoticeView: View {
    var completion: () -> ()
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 33) {
                Text("모두의 공간이에요")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("""
                     AzitTalk의 모니터링, 신고를 통해 확인되는 모든 정책 위반에 대해서 강력한 제제를 부과합니다.
                     
                     선정적인 내용을 포함한 글, 광고성 글, 판매 글은 모두 영구 정지 항목에 포함됩니다.

                     아름다운 AzitTalk 문화를 만들어 나가기 위해 서로 존중하는 Learner가 되어주세요.
                    """)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    completion()
                } label: {
                    Text("주의사항을 인지했어요")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.all, 29.5)
            .background(Color(uiColor: .systemPink))
        }
        .ignoresSafeArea()
    }
}
