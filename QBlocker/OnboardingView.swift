//
//  OnboardingView.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import AppKit
import SwiftUI

@MainActor
final class OnboardingWindowController {
    static let shared = OnboardingWindowController()

    private var window: NSWindow?

    private init() {}

    func showIfNeeded(settings: AppSettings, environment: AppEnvironment = .live) {
        guard !settings.firstRunComplete else {
            return
        }

        show(settings: settings, environment: environment)
    }

    func show(settings: AppSettings, environment: AppEnvironment = .live) {
        if window == nil {
            let rootView = OnboardingView(settings: settings, environment: environment)
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Welcome to QBlocker"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 560, height: 420))
            window.minSize = NSSize(width: 560, height: 420)
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

struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var environment: AppEnvironment

    @State private var step = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == step ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: steps[step].systemImage)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.accentColor)

                Text(steps[step].title)
                    .font(.title2.weight(.semibold))

                Text(steps[step].message)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            stepContent

            Spacer()

            HStack {
                if step > 0 {
                    Button("Back") {
                        step -= 1
                    }
                }

                Spacer()

                Button(primaryActionTitle) {
                    primaryAction()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(minWidth: 560, minHeight: 420, alignment: .leading)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .welcome:
                VStack(alignment: .leading, spacing: 8) {
                    Label("Hold Command-Q to intentionally quit", systemImage: "command")
                    Label("Release early to cancel accidental quits", systemImage: "hand.raised")
                    Label("Choose startup and app protection preferences", systemImage: "switch.2")
                }
                .foregroundStyle(.secondary)

        case .permission:
            VStack(alignment: .leading, spacing: 12) {
                StatusCapsule(
                    text: environment.accessibilityTrusted ? "Accessibility granted" : "Accessibility required",
                    systemImage: environment.accessibilityTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                    tint: environment.accessibilityTrusted ? .green : .orange
                )

                HStack {
                    Button("Open System Settings") {
                        environment.openAccessibilitySettings()
                    }

                    Button("Request Permission") {
                        environment.requestAccessibility()
                    }

                    Button("Refresh") {
                        environment.refresh()
                    }
                }
            }

            case .startup:
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Open QBlocker at Login", isOn: Binding(
                        get: { environment.launchAtLogin },
                        set: { environment.setLaunchAtLogin($0) }
                    ))

                    if let launchAtLoginError = environment.launchAtLoginError {
                        Text(launchAtLoginError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

            case .rules:
                Picker("Rule Mode", selection: $settings.listMode) {
                ForEach(ListMode.allCases) { mode in
                    Text(mode.shortTitle).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var currentStep: OnboardingStep {
        steps[step]
    }

    private var primaryActionTitle: String {
        if currentStep == .rules {
            return "Done"
        }

        return "Continue"
    }

    private func primaryAction() {
        if currentStep == .permission {
            environment.refresh()
            guard environment.accessibilityTrusted else {
                environment.openAccessibilitySettings()
                return
            }
        }

        if step < steps.count - 1 {
            step += 1
        } else {
            settings.firstRunComplete = true
            environment.restartListener()
            OnboardingWindowController.shared.close()
        }
    }

    private var steps: [OnboardingStep] {
        [.welcome, .permission, .startup, .rules]
    }
}

private enum OnboardingStep {
    case welcome
    case permission
    case startup
    case rules

    var systemImage: String {
        switch self {
        case .welcome:
            "command.circle"
        case .permission:
            "accessibility"
        case .startup:
            "power"
        case .rules:
            "list.bullet.rectangle"
        }
    }

    var title: String {
        switch self {
        case .welcome:
            "Stop accidental Command-Q quits"
        case .permission:
            "Grant Accessibility permission"
        case .startup:
            "Start QBlocker automatically"
        case .rules:
            "Choose where QBlocker protects you"
        }
    }

    var message: String {
        switch self {
        case .welcome:
            "QBlocker catches Command-Q before the frontmost app quits, then asks you to keep holding when you really mean it."
        case .permission:
            "macOS requires Accessibility permission for keyboard interception. Because QBlocker now uses the Churro Studio app identity, you may need to grant this again."
        case .startup:
            "Keep QBlocker running after you restart your Mac so accidental quits are blocked before you start working."
        case .rules:
            "Start with protection everywhere, then add exceptions later from Settings."
        }
    }
}

private struct StatusCapsule: View {
    let text: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.callout.weight(.medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

#Preview {
    OnboardingView(
        settings: .preview(firstRunComplete: false),
        environment: .preview(accessibilityTrusted: false, listenerRunning: false),
        
    )
}
