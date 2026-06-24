//
//  FirstRunViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized as SwiftUI content.
//

import AppKit
import SwiftUI

@MainActor
final class FirstRunWindowController {
    static let shared = FirstRunWindowController()

    private var window: NSWindow?

    private init() {}

    func showIfNeeded(settings: AppSettings) {
        guard !settings.firstRunComplete else {
            return
        }

        if window == nil {
            let rootView = FirstRunView(settings: settings)
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Welcome to QBlocker"
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

struct FirstRunView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "command")
                .font(.system(size: 42))
                .foregroundStyle(Color.accentColor)

            Text("QBlocker is protecting Cmd-Q")
                .font(.title2.weight(.semibold))

            Text("Hold Cmd-Q when you really mean to quit. Release it quickly and QBlocker will count that as an accidental quit.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Open Preferences") {
                    settings.firstRunComplete = true
                    FirstRunWindowController.shared.close()
                    PreferencesWindowController.shared.show(settings: settings)
                }
                .buttonStyle(.borderedProminent)

                Button("Done") {
                    settings.firstRunComplete = true
                    FirstRunWindowController.shared.close()
                }
            }
        }
        .padding(28)
        .frame(width: 520, alignment: .leading)
    }
}
