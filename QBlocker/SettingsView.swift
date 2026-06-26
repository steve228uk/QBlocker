//
//  SettingsView.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct PreferencesView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        TabView {
            GeneralSettingsView(settings: settings, environment: environment)
                .tabItem {
                    Label("General", systemImage: "slider.horizontal.3")
                }

            RulesSettingsView(settings: settings)
                .tabItem {
                    Label("Rules", systemImage: "list.bullet.rectangle")
                }

            PermissionsSettingsView(environment: environment)
                .tabItem {
                    Label("Permissions", systemImage: "accessibility")
                }
        }
        .padding(24)
        .frame(minWidth: 640, minHeight: 480)
    }
}

struct RulesSettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var selection = Set<ExcludedApp.ID>()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Rule Mode", selection: $settings.listMode) {
                    ForEach(ListMode.allCases) { mode in
                        Text(mode.shortTitle).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Text(settings.listMode.title)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if settings.apps.isEmpty {
                ContentUnavailableView {
                    Label("No Apps Added", systemImage: "app.badge")
                } description: {
                    Text(emptyStateText)
                } actions: {
                    Button {
                        addApps()
                    } label: {
                        Label("Add Apps...", systemImage: "plus")
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 240)
            } else {
                List(settings.apps, selection: $selection) { app in
                    AppRuleRow(app: app)
                }
                .frame(minHeight: 260)
                .onDeleteCommand {
                    removeSelection()
                }
            }

            HStack {
                Button {
                    addApps()
                } label: {
                    Label("Add Apps...", systemImage: "plus")
                }

                Button {
                    removeSelection()
                } label: {
                    Label("Remove", systemImage: "minus")
                }
                .disabled(selection.isEmpty)

                Spacer()
            }
        }
    }

    private var emptyStateText: String {
        switch settings.listMode {
        case .blocklist:
            "QBlocker protects every app until you add exceptions."
        case .allowlist:
            "Add apps that should require holding Command-Q before quitting."
        }
    }

    private func addApps() {
        let panel = NSOpenPanel()
        panel.title = "Choose Apps"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.applicationBundle]

        guard panel.runModal() == .OK else {
            return
        }

        let apps = panel.urls.compactMap { url -> ExcludedApp? in
            guard let bundleIdentifier = Bundle(url: url)?.bundleIdentifier else {
                return nil
            }

            let name = FileManager.default.displayName(atPath: url.path)
            return ExcludedApp(name: name, bundleID: bundleIdentifier)
        }

        settings.addApps(apps)
    }

    private func removeSelection() {
        settings.removeApps(with: selection)
        selection.removeAll()
    }
}

struct PermissionsSettingsView: View {
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        Form {
            Section("Accessibility") {
                StatusRow(
                    title: "Permission",
                    status: environment.accessibilityTrusted ? "Granted" : "Required",
                    systemImage: environment.accessibilityTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                    tint: environment.accessibilityTrusted ? .green : .orange
                ) {
                    Button("Open System Settings") {
                        environment.openAccessibilitySettings()
                    }

                    if !environment.accessibilityTrusted {
                        Button("Request Permission") {
                            environment.requestAccessibility()
                        }
                    }

                    Button("Refresh") {
                        environment.refresh()
                    }
                }

                Text("QBlocker needs Accessibility permission to intercept Command-Q before the frontmost app quits. After the Churro Studio bundle identity change, macOS may ask you to grant permission again.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Listener") {
                StatusRow(
                    title: "Keyboard listener",
                    status: environment.listenerRunning ? "Running" : "Stopped",
                    systemImage: environment.listenerRunning ? "waveform.path.ecg" : "pause.circle.fill",
                    tint: environment.listenerRunning ? .green : .red
                ) {
                    Button("Restart") {
                        environment.restartListener()
                    }
                }

                if let listenerError = environment.listenerError {
                    Text(listenerError)
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct AppRuleRow: View {
    let app: ExcludedApp

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                Text(app.bundleID)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(.vertical, 3)
    }

    private var icon: NSImage {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }

        return NSWorkspace.shared.icon(for: .applicationBundle)
    }
}

private struct StatusRow<Actions: View>: View {
    let title: String
    let status: String
    let systemImage: String
    let tint: Color
    @ViewBuilder var actions: Actions

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            actions
        }
    }
}

#Preview("Populated") {
    PreferencesView(settings: .preview(), environment: .preview())
}

#Preview("Empty Rules") {
    PreferencesView(
        settings: .preview(apps: []),
        environment: .preview(accessibilityTrusted: false, listenerRunning: false)
    )
}
