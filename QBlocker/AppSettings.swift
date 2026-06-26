//
//  AppSettings.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var accidentalQuits: Int {
        didSet { defaults.set(accidentalQuits, forKey: Keys.accidentalQuits) }
    }

    @Published var firstRunComplete: Bool {
        didSet { defaults.set(firstRunComplete, forKey: Keys.firstRunComplete) }
    }

    @Published var listMode: ListMode {
        didSet { defaults.set(listMode.rawValue, forKey: Keys.listMode) }
    }

    @Published var delayPresses: Int {
        didSet { defaults.set(delayPresses, forKey: Keys.delayPresses) }
    }

    @Published private(set) var apps: [ExcludedApp] {
        didSet { store.save(apps) }
    }

    var listedBundleIdentifiers: Set<String> {
        Set(apps.map(\.bundleID))
    }

    private let defaults: UserDefaults
    private let store: AppRuleStore

    init(
        defaults: UserDefaults = .standard,
        store: AppRuleStore = AppRuleStore(),
        legacyDefaults: UserDefaults? = UserDefaults(suiteName: Legacy.bundleIdentifier)
    ) {
        self.defaults = defaults
        self.store = store

        Self.migrateLegacyDefaultsIfNeeded(defaults: defaults, legacyDefaults: legacyDefaults)

        defaults.register(defaults: [
            Keys.accidentalQuits: 0,
            Keys.firstRunComplete: false,
            Keys.listMode: ListMode.blocklist.rawValue,
            Keys.delayPresses: 4
        ])

        accidentalQuits = defaults.integer(forKey: Keys.accidentalQuits)
        firstRunComplete = defaults.bool(forKey: Keys.firstRunComplete)
        listMode = ListMode(rawValue: defaults.integer(forKey: Keys.listMode)) ?? .blocklist
        delayPresses = max(1, defaults.integer(forKey: Keys.delayPresses))
        apps = store.load()
    }

    func addApps(_ newApps: [ExcludedApp]) {
        var byBundleID = Dictionary(uniqueKeysWithValues: apps.map { ($0.bundleID, $0) })
        for app in newApps {
            byBundleID[app.bundleID] = app
        }

        apps = Array(byBundleID.values).sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    func removeApps(with ids: Set<ExcludedApp.ID>) {
        apps.removeAll { ids.contains($0.id) }
    }

    func logAccidentalQuit() {
        accidentalQuits += 1
    }

    private enum Keys {
        static let accidentalQuits = "accidentalQuits"
        static let firstRunComplete = "firstRunComplete"
        static let listMode = "listMode"
        static let delayPresses = "delay"
        static let migratedLegacyDefaults = "migratedLegacyDefaultsFromWeAreCocoon"
    }

    private enum Legacy {
        static let bundleIdentifier = "uk.co.wearecocoon.QBlocker"
    }

    private static func migrateLegacyDefaultsIfNeeded(defaults: UserDefaults, legacyDefaults: UserDefaults?) {
        guard !defaults.bool(forKey: Keys.migratedLegacyDefaults),
              let legacyDefaults else {
            return
        }

        let legacyValues = legacyDefaults.dictionaryRepresentation()
        for key in [
            Keys.accidentalQuits,
            Keys.firstRunComplete,
            Keys.listMode,
            Keys.delayPresses
        ] where defaults.object(forKey: key) == nil {
            if let value = legacyValues[key] {
                defaults.set(value, forKey: key)
            }
        }

        defaults.set(true, forKey: Keys.migratedLegacyDefaults)
    }

}

extension AppSettings {
    static func preview(
        accidentalQuits: Int = 8,
        firstRunComplete: Bool = false,
        listMode: ListMode = .blocklist,
        delayPresses: Int = 4,
        apps: [ExcludedApp] = [
            ExcludedApp(name: "Safari", bundleID: "com.apple.Safari"),
            ExcludedApp(name: "Xcode", bundleID: "com.apple.dt.Xcode")
        ]
    ) -> AppSettings {
        let defaults = UserDefaults(suiteName: "QBlockerPreview-\(UUID().uuidString)")!
        defaults.set(accidentalQuits, forKey: Keys.accidentalQuits)
        defaults.set(firstRunComplete, forKey: Keys.firstRunComplete)
        defaults.set(listMode.rawValue, forKey: Keys.listMode)
        defaults.set(delayPresses, forKey: Keys.delayPresses)

        return AppSettings(
            defaults: defaults,
            store: AppRuleStore(appDirectory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        ).withPreviewApps(apps)
    }

    private func withPreviewApps(_ previewApps: [ExcludedApp]) -> AppSettings {
        apps = previewApps
        return self
    }
}
