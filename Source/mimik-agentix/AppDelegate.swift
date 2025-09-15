//
//  AppDelegate.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-15.
//

import UIKit
import AppAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    var currentAuthorizationFlow: (any OIDExternalUserAgentSession)?

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let flow = currentAuthorizationFlow,
           flow.resumeExternalUserAgentFlow(with: url) {
            currentAuthorizationFlow = nil
            return true
        }
        return false
    }
}
