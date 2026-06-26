//
//  SettingsWindowController.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    private init() {}

    func show(settings: AppSettings = .shared, environment: AppEnvironment = .live) {
        if window == nil {
            let rootView = PreferencesView(settings: settings, environment: environment)
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "QBlocker Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 700, height: 520))
            window.minSize = NSSize(width: 640, height: 480)
            window.setFrameAutosaveName("QBlockerSettingsWindow")
            window.center()
            self.window = window
        }

        NSApplication.shared.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
