//
//  AccessibilityWindowController.swift
//  QBlocker
//
//  Created by Stephen Radford on 05/05/2016.
//  Modernized as a SwiftUI window presenter.
//

import AppKit
import SwiftUI

@MainActor
final class AccessibilityWindowController {
    static let shared = AccessibilityWindowController()

    private var window: NSWindow?

    private init() {}

    func show() {
        if window == nil {
            let rootView = AccessibilityPromptView()
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Accessibility Required"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 520, height: 260))
            window.center()
            self.window = window
        }

        NSApplication.shared.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        window?.orderOut(nil)
    }
}
