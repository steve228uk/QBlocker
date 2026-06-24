//
//  ExcludeViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized as SwiftUI preferences.
//

import SwiftUI
import UniformTypeIdentifiers

struct PreferencesView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        TabView {
            RulesPreferencesView(settings: settings)
                .tabItem {
                    Label("Rules", systemImage: "list.bullet.rectangle")
                }

            GeneralPreferencesView(settings: settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .padding(24)
        .frame(minWidth: 620, minHeight: 460)
    }
}

struct RulesPreferencesView: View {
    @ObservedObject var settings: AppSettings
    @State private var selection = Set<ExcludedApp.ID>()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Rule Mode", selection: $settings.listMode) {
                ForEach(ListMode.allCases) { mode in
                    Text(mode.shortTitle).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text(settings.listMode.title)
                .font(.callout)
                .foregroundStyle(.secondary)

            List(settings.apps, selection: $selection) { app in
                HStack {
                    Image(nsImage: NSWorkspace.shared.icon(for: .applicationBundle))
                        .resizable()
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                        Text(app.bundleID)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(minHeight: 220)

            HStack {
                Button {
                    addApps()
                } label: {
                    Label("Add", systemImage: "plus")
                }

                Button {
                    settings.removeApps(with: selection)
                    selection.removeAll()
                } label: {
                    Label("Remove", systemImage: "minus")
                }
                .disabled(selection.isEmpty)

                Spacer()
            }
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
}
