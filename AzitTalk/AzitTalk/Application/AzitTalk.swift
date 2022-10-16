//
//  AzitTalk.swift
//  NC1
//
//  Created by Shin Jae Ung on 2022/04/25.
//

import SwiftUI

@main
struct AzitTalk: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            SplashView()
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    AppDelegate.orientationLock = .portrait
                }
        }
    }
}
