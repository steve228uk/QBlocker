//
//  AccessibilityViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 05/05/2016.
//  Modernized as SwiftUI content.
//

import SwiftUI

struct AccessibilityPromptView: View {
    @State private var trusted = AccessibilityPermission.isTrusted

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: trusted ? "checkmark.shield" : "keyboard.badge.eye")
                .font(.system(size: 42))
                .foregroundStyle(trusted ? .green : .accentColor)

            Text(trusted ? "QBlocker is ready" : "Accessibility permission is required")
                .font(.title2.weight(.semibold))

            Text("QBlocker needs Accessibility permission to detect Cmd-Q, check whether the frontmost app uses that shortcut, and cancel accidental quits.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Open System Settings") {
                    AccessibilityPermission.openSystemSettings()
                }
                .buttonStyle(.borderedProminent)

                Button("Request Permission") {
                    trusted = AccessibilityPermission.request()
                    KeyListener.shared.restartIfPossible()
                }

                Button("Refresh") {
                    trusted = AccessibilityPermission.isTrusted
                    KeyListener.shared.restartIfPossible()

                    if trusted {
                        AccessibilityWindowController.shared.close()
                        FirstRunWindowController.shared.showIfNeeded(settings: .shared)
                    }
                }
            }
        }
        .padding(28)
        .frame(width: 520, alignment: .leading)
    }
}
