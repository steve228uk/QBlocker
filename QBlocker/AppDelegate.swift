//
//  AppDelegate.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        HUDPresenter.shared.prepare()
        KeyListener.shared.configure(settings: .shared)
        AppEnvironment.live.refresh()

        if AccessibilityPermission.isTrusted {
            try? KeyListener.shared.start()
        }

        OnboardingWindowController.shared.showIfNeeded(settings: .shared, environment: .live)
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyListener.shared.stop()
    }
}
