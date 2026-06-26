//
//  ListMode.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import Foundation

enum ListMode: Int, CaseIterable, Codable, Identifiable {
    case blocklist = 0
    case allowlist = 1

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .blocklist:
            "Protect all apps except the list below"
        case .allowlist:
            "Protect only the apps below"
        }
    }

    var shortTitle: String {
        switch self {
        case .blocklist:
            "All Except"
        case .allowlist:
            "Only These"
        }
    }

    func shouldProtect(bundleIdentifier: String, listedBundleIdentifiers: Set<String>) -> Bool {
        let isListed = listedBundleIdentifiers.contains(bundleIdentifier)

        switch self {
        case .blocklist:
            return !isListed
        case .allowlist:
            return isListed
        }
    }
}
