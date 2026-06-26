//
//  AppModels.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import Foundation

struct ExcludedApp: Codable, Hashable, Identifiable {
    var id: String { bundleID }

    var name: String
    var bundleID: String
}

struct AppRuleStore {
    private let fileManager: FileManager
    private let fileURL: URL

    init(fileManager: FileManager = .default, appDirectory: URL? = nil) {
        self.fileManager = fileManager

        let directory: URL
        if let appDirectory {
            directory = appDirectory
        } else {
            let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            directory = supportDirectory.appendingPathComponent("QBlocker", isDirectory: true)
        }

        self.fileURL = directory.appendingPathComponent("app-rules.json")
    }

    func load() -> [ExcludedApp] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([ExcludedApp].self, from: data).sortedByName()
        } catch {
            NSLog("Could not load app rules: \(error.localizedDescription)")
            return []
        }
    }

    func save(_ apps: [ExcludedApp]) {
        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let data = try JSONEncoder().encode(apps.sortedByName())
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            NSLog("Could not save app rules: \(error.localizedDescription)")
        }
    }
}

private extension Array where Element == ExcludedApp {
    func sortedByName() -> [ExcludedApp] {
        sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
