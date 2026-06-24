//
//  ListMode.swift
//  QBlocker
//
//  Created by Florian Schliep on 25.05.16.
//  Modernized for SwiftUI.
//

import Foundation

enum ListMode: Int, CaseIterable, Codable, Identifiable {
    case blocklist = 0
    case allowlist = 1

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .blocklist:
            "Block Cmd-Q in every app except the list below"
        case .allowlist:
            "Only block Cmd-Q in the apps below"
        }
    }

    var shortTitle: String {
        switch self {
        case .blocklist:
            "Blocklist"
        case .allowlist:
            "Allowlist"
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
