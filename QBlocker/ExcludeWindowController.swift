//
//  ExcludeWindowController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized as a SwiftUI preferences window presenter.
//

import AppKit
import SwiftUI

@MainActor
final class PreferencesWindowController {
    static let shared = PreferencesWindowController()

    private var window: NSWindow?

    private init() {}

    func show(settings: AppSettings = .shared) {
        if window == nil {
            let rootView = PreferencesView(settings: settings)
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "QBlocker Preferences"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 620, height: 460))
            window.center()
            self.window = window
        }

        NSApplication.shared.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
