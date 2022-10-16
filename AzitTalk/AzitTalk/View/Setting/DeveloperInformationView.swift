//
//  DeveloperInformationView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/10/03.
//

import SwiftUI

struct DeveloperInformationView: View {
    let nickName: String
    let email: String
    let phoneNumber: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 60) {
            HStack { Spacer() }
            VStack(alignment: .leading) {
                Text("2022 Cohort,")
                    .fontWeight(.bold)
                Text(nickName)
            }
            VStack(alignment: .leading) {
                Text("이메일")
                    .fontWeight(.bold)
                Text(email)
            }
            if !phoneNumber.isEmpty {
                VStack(alignment: .leading) {
                    Text("연락처")
                        .fontWeight(.bold)
                    Text(phoneNumber)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
