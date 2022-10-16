//
//  MessageView.swift
//  NC1
//
//  Created by Shin Jae Ung on 2022/04/30.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        if self.message.senderUID == FirebaseManager.shared.auth.currentUser?.uid {
            HStack(alignment: .bottom) {
                Spacer()
                Text(self.message.time.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(self.message.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.init(uiColor: .systemPink))
                    .cornerRadius(16)
                    .lineLimit(5)
            }
            .background(
                SpeechBubbleTail(position: .right)
                    .foregroundColor(.init(uiColor: .systemPink))
            )
            .padding(.horizontal)
        } else {
            VStack(spacing: 5) {
                HStack {
                    Text(self.message.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Text(self.message.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.init(white: 0.9))
                        .cornerRadius(10)
                        .lineLimit(5)
                        Text(self.message.time.formattedTime)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    Spacer()
                }
            }
            .background(
                SpeechBubbleTail(position: .left)
                    .foregroundColor(.init(white: 0.9))
            )
            .padding(.horizontal)
        }
    }
}

fileprivate struct SpeechBubbleTail: Shape {
    enum Position {
        case left
        case right
    }
    let position: Position
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch self.position {
        case .left:
            let startPoint = CGPoint(x: rect.minX - 5, y: rect.maxY)
            path.move(to: startPoint)
            path.addQuadCurve(
                to: CGPoint(x: startPoint.x + 20, y: startPoint.y - 20),
                control: CGPoint(x: startPoint.x + 15, y: startPoint.y)
            )
            path.addLine(to: CGPoint(
                x: startPoint.x + 5,
                y: startPoint.y - 20))
            path.addQuadCurve(
                to: startPoint,
                control: CGPoint(x: startPoint.x + 5, y: startPoint.y)
            )
        case .right:
            let startPoint = CGPoint(x: rect.maxX + 5, y: rect.maxY)
            path.move(to: startPoint)
            path.addQuadCurve(
                to: CGPoint(x: startPoint.x - 20, y: startPoint.y - 20),
                control: CGPoint(x: startPoint.x - 15, y: startPoint.y)
            )
            path.addLine(to: CGPoint(
                x: startPoint.x - 5,
                y: startPoint.y - 20))
            path.addQuadCurve(
                to: startPoint,
                control: CGPoint(x: startPoint.x - 5, y: startPoint.y)
            )
        }
        return path
    }
}
