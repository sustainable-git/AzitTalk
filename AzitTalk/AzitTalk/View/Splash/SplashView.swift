//
//  SplashView.swift
//  AzitTalk
//
//  Created by Shin Jae Ung on 2022/08/27.
//

import SwiftUI

struct SplashView: View {
    @ObservedObject private var viewModel: SplashViewModel = SplashViewModel()
    
    var body: some View {
        VStack {
            PartialCircle(startDegree: 0, endDegree: 360, position: .rightTop)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.circleTop, .circleBottom]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Spacer()
                .frame(height: 50)
            Text("AzitTalk")
                .font(.system(size: 55))
            Spacer()
                .frame(height: 14)
            Text("우리 사이 이야기")
                .font(.system(size: 13))
                .fontWeight(.bold)
            Spacer()
                .frame(height: 50)
            PartialCircle(startDegree: 0, endDegree: 360, position: .leftBottom)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.circleTop, .circleBottom]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: self.$viewModel.isLoggedIn) {
            ChatListView(isLogin: self.$viewModel.isLoggedIn)
        }
        .fullScreenCover(isPresented: self.$viewModel.isUnLoggedIn) {
            EntranceView()
        }
        .onAppear {
            self.viewModel.onAppear()
        }
    }
}

fileprivate struct PartialCircle: Shape {
    enum Position {
        case rightTop
        case leftBottom
    }
    let startDegree: CGFloat
    let endDegree: CGFloat
    let position: Position
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height)
        var path = Path()
        var startPoint: CGPoint {
            switch self.position {
            case .rightTop : return CGPoint(x: rect.maxX, y: rect.minY)
            case .leftBottom : return CGPoint(x: rect.minX, y: rect.maxY)
            }
        }
        path.move(to: startPoint)
        path.addLine(to: CGPoint(
            x: startPoint.x - radius * cos(startDegree / (2 * Double.pi)),
            y: startPoint.y + radius * sin(startDegree / (2 * Double.pi)))
        )
        path.addArc(
            center: startPoint,
            radius: radius,
            startAngle: Angle(degrees: startDegree),
            endAngle: -Angle(degrees: endDegree),
            clockwise: true
        )
        path.addLine(to: startPoint)
        return path
    }
}
