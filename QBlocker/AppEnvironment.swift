//
//  AppEnvironment.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    static let live = AppEnvironment()

    @Published private(set) var accessibilityTrusted: Bool
    @Published private(set) var listenerRunning: Bool
    @Published private(set) var listenerError: String?
    @Published private(set) var launchAtLogin: Bool
    @Published private(set) var launchAtLoginError: String?

    private let allowsSystemChanges: Bool

    init(
        accessibilityTrusted: Bool = AccessibilityPermission.isTrusted,
        listenerRunning: Bool = KeyListener.shared.isRunning,
        listenerError: String? = KeyListener.shared.lastError,
        launchAtLogin: Bool = AtLogin.enabled,
        allowsSystemChanges: Bool = true
    ) {
        self.accessibilityTrusted = accessibilityTrusted
        self.listenerRunning = listenerRunning
        self.listenerError = listenerError
        self.launchAtLogin = launchAtLogin
        self.allowsSystemChanges = allowsSystemChanges

        guard allowsSystemChanges else {
            return
        }

        KeyListener.shared.$isRunning
            .receive(on: RunLoop.main)
            .assign(to: &$listenerRunning)

        KeyListener.shared.$lastError
            .receive(on: RunLoop.main)
            .assign(to: &$listenerError)
    }

    static func preview(
        accessibilityTrusted: Bool = true,
        listenerRunning: Bool = true,
        listenerError: String? = nil,
        launchAtLogin: Bool = true
    ) -> AppEnvironment {
        AppEnvironment(
            accessibilityTrusted: accessibilityTrusted,
            listenerRunning: listenerRunning,
            listenerError: listenerError,
            launchAtLogin: launchAtLogin,
            allowsSystemChanges: false
        )
    }

    func refresh() {
        guard allowsSystemChanges else {
            return
        }

        accessibilityTrusted = AccessibilityPermission.isTrusted
        listenerRunning = KeyListener.shared.isRunning
        listenerError = KeyListener.shared.lastError
        launchAtLogin = AtLogin.enabled
    }

    func openAccessibilitySettings() {
        guard allowsSystemChanges else {
            return
        }

        AccessibilityPermission.openSystemSettings()
    }

    @discardableResult
    func requestAccessibility() -> Bool {
        guard allowsSystemChanges else {
            return accessibilityTrusted
        }

        accessibilityTrusted = AccessibilityPermission.request()
        KeyListener.shared.restartIfPossible()
        refresh()
        return accessibilityTrusted
    }

    func restartListener() {
        guard allowsSystemChanges else {
            return
        }

        KeyListener.shared.restartIfPossible()
        refresh()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        guard allowsSystemChanges else {
            launchAtLogin = enabled
            return
        }

        do {
            try AtLogin.setEnabled(enabled)
            launchAtLogin = AtLogin.enabled
            launchAtLoginError = nil
        } catch {
            launchAtLogin = AtLogin.enabled
            launchAtLoginError = error.localizedDescription
        }
    }
}
