//
//  StatusMenuController.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import SwiftUI

@main
struct QBlockerApplication: SwiftUI.App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = AppSettings.shared
    @StateObject private var environment = AppEnvironment.live

    var body: some Scene {
        MenuBarExtra {
            StatusMenuView(settings: settings, environment: environment)
        } label: {
            Image(systemName: "command")
        }
        .menuBarExtraStyle(.menu)
    }
}

struct StatusMenuView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        Text(blockedCountText)

        if !environment.accessibilityTrusted {
            Button("Grant Accessibility Permission") {
                OnboardingWindowController.shared.show(settings: settings, environment: environment)
            }
        } else if !environment.listenerRunning {
            Button("Restart Listener") {
                environment.restartListener()
            }
        }

        Divider()

            Button("Settings...") {
                SettingsWindowController.shared.show(settings: settings, environment: environment)
            }

            Divider()

        Button("Quit QBlocker") {
            NSApplication.shared.terminate(nil)
        }
    }

    private var blockedCountText: String {
        "\(settings.accidentalQuits) \(settings.accidentalQuits == 1 ? "Quit" : "Quits") Blocked"
    }
}

#Preview("Running") {
    StatusMenuView(settings: .preview(accidentalQuits: 1), environment: .preview())
}

#Preview("Needs Permission") {
    StatusMenuView(
        settings: .preview(accidentalQuits: 12),
        environment: .preview(accessibilityTrusted: false, listenerRunning: false)
    )
}
