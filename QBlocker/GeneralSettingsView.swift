//
//  GeneralSettingsView.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        Form {
            Section("Protection") {
                LabeledContent("Hold duration") {
                    Stepper(value: $settings.delayPresses, in: 1...12) {
                        Text("\(settings.delayPresses) seconds")
                            .monospacedDigit()
                    }
                }

                Text("QBlocker shows a progress HUD while Command-Q is held. Releasing before the hold finishes cancels the quit.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Startup") {
                Toggle("Open QBlocker at Login", isOn: Binding(
                    get: { environment.launchAtLogin },
                    set: { environment.setLaunchAtLogin($0) }
                ))
            }

            if let launchAtLoginError = environment.launchAtLoginError {
                Text(launchAtLoginError)
                    .foregroundStyle(.red)
            }

            Section("Stats") {
                LabeledContent("Accidental quits blocked", value: "\(settings.accidentalQuits)")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView(
        settings: .preview(),
        environment: .preview()
    )
    .padding()
}
