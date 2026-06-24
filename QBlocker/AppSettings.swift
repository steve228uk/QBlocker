//
//  AppSettings.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized from database-backed persistence to Codable storage.
//

import Combine
import Foundation

final class AppSettings: ObservableObject {
    nonisolated(unsafe) static let shared = AppSettings()

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

    init(defaults: UserDefaults = .standard, store: AppRuleStore = AppRuleStore()) {
        self.defaults = defaults
        self.store = store

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
    }
}
