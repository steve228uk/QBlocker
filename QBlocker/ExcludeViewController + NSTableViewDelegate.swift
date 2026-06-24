//
//  AccessibilityPermission.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized as shared Accessibility helpers.
//

import AppKit
import ApplicationServices

enum AccessibilityPermission {
    private static let promptOptionKey = "AXTrustedCheckOptionPrompt"

    static var isTrusted: Bool {
        AXIsProcessTrustedWithOptions(options(prompt: false))
    }

    @discardableResult
    static func request() -> Bool {
        AXIsProcessTrustedWithOptions(options(prompt: true))
    }

    static func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }

        NSWorkspace.shared.open(url)
    }

    private static func options(prompt: Bool) -> CFDictionary {
        [promptOptionKey: prompt] as CFDictionary
    }
}
