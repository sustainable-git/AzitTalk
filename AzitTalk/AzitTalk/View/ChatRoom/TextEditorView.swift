//
//  TextEditorView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/10/10.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var string: String
    @State var textEditorHeight : CGFloat = 20
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(string)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(10)
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: ViewHeightKey.self,
                            value: $0.frame(in: .local).size.height)
                    }
                )
            TextEditor(text: $string)
                .font(.system(.body))
                .frame(height: max(40, textEditorHeight))
                .focused(self.$isFocused)
            
            Text("메시지를 입력하세요")
                .foregroundColor(.init(uiColor: .systemGray3))
                .opacity(self.isFocused || !self.string.isEmpty ? 0 : 1)
                .onTapGesture { self.isFocused = true }
        }
        .padding(.leading, 15)
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0}
    }
}


fileprivate struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
