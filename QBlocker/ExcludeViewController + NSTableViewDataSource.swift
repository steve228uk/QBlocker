//
//  GeneralPreferencesView.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized as SwiftUI preferences.
//

import SwiftUI

struct GeneralPreferencesView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject private var listener = KeyListener.shared
    @State private var launchAtLogin = AtLogin.enabled
    @State private var launchAtLoginError: String?

    var body: some View {
        Form {
            LabeledContent("Hold duration") {
                Stepper(value: $settings.delayPresses, in: 1...12) {
                    Text("\(settings.delayPresses) seconds")
                }
            }

            Button(launchAtLogin ? "Disable Open at Login" : "Enable Open at Login") {
                setLaunchAtLogin(!launchAtLogin)
            }

            if let launchAtLoginError {
                Text(launchAtLoginError)
                    .foregroundStyle(.red)
            }

            LabeledContent("Accessibility") {
                HStack {
                    Text(AccessibilityPermission.isTrusted ? "Granted" : "Required")
                        .foregroundColor(AccessibilityPermission.isTrusted ? .secondary : .red)

                    Button("Open Settings") {
                        AccessibilityPermission.openSystemSettings()
                    }

                    if !AccessibilityPermission.isTrusted {
                        Button("Request") {
                            AccessibilityPermission.request()
                        }
                    }
                }
            }

            LabeledContent("Listener") {
                HStack {
                    Text(listener.isRunning ? "Running" : "Stopped")
                        .foregroundColor(listener.isRunning ? .secondary : .red)

                    Button("Restart") {
                        listener.restartIfPossible()
                    }
                }
            }

            if let lastError = listener.lastError {
                Text(lastError)
                    .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try AtLogin.setEnabled(enabled)
            launchAtLogin = AtLogin.enabled
            launchAtLoginError = nil
        } catch {
            launchAtLogin = AtLogin.enabled
            launchAtLoginError = error.localizedDescription
        }
    }
}
