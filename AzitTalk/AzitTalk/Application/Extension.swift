//
//  Extension.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/07/16.
//

import SwiftUI

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    return Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

extension Date {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    var formattedTimeWithDate: String {
        if Calendar.current.compare(self, to: .now, toGranularity: .day) == .orderedSame {
            Date.dateFormatter.dateFormat = "H:mm"
            return Date.dateFormatter.string(from: self)
        } else {
            Date.dateFormatter.dateFormat = "yyyy. M. dd"
            return Date.dateFormatter.string(from: self)
        }
    }
    var formattedTime: String {
        Date.dateFormatter.dateFormat = "H:mm"
        return Date.dateFormatter.string(from: self)
    }
    var formattedDate: String {
        Date.dateFormatter.dateFormat = "yyyy. M. dd."
        return Date.dateFormatter.string(from: self)
    }
}

extension Color {
    static let circleTop: Color = Color(uiColor: #colorLiteral(red: 1, green: 0.4705882353, blue: 0.5803921569, alpha: 1))
    static let circleBottom: Color = Color(uiColor: #colorLiteral(red: 0.8784313725, green: 0.1294117647, blue: 0.3019607843, alpha: 1))
}

enum Constant {
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
