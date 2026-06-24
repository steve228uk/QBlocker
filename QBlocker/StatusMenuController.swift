//
//  StatusMenuController.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Modernized as the SwiftUI app entrypoint.
//

import SwiftUI

@main
struct QBlockerApplication: SwiftUI.App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        MenuBarExtra {
            StatusMenuView(settings: settings)
        } label: {
            Image("Menu Bar")
        }
        .menuBarExtraStyle(.menu)
    }
}

struct StatusMenuView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject private var listener = KeyListener.shared
    @State private var launchAtLogin = AtLogin.enabled
    @State private var launchAtLoginError: String?

    var body: some View {
        Text("\(settings.accidentalQuits) Quits Blocked")

        if !AccessibilityPermission.isTrusted {
            Button("Grant Accessibility Permission") {
                AccessibilityWindowController.shared.show()
            }
        } else if !listener.isRunning {
            Button("Restart Listener") {
                listener.restartIfPossible()
            }
        }

        Divider()

        Button("Preferences...") {
            PreferencesWindowController.shared.show(settings: settings)
        }

        Button(launchAtLogin ? "Disable Open at Login" : "Enable Open at Login") {
            setLaunchAtLogin(!launchAtLogin)
        }

        if let launchAtLoginError {
            Text(launchAtLoginError)
        }

        Divider()

        Button("Quit QBlocker") {
            NSApplication.shared.terminate(nil)
        }
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
