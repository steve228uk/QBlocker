//
//  AppDelegate.swift
//  QBlocker
//
//  Created by Stephen Radford on 01/05/2016.
//  Modernized for SwiftUI lifecycle.
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        HUDAlert.shared.prepare()
        KeyListener.shared.configure(settings: .shared)

        if AccessibilityPermission.isTrusted {
            try? KeyListener.shared.start()
            FirstRunWindowController.shared.showIfNeeded(settings: .shared)
        } else {
            AccessibilityWindowController.shared.show()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyListener.shared.stop()
    }
}
