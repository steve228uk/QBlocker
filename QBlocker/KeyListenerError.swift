//
//  KeyListenerError.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import Foundation

enum KeyListenerError: LocalizedError {
    case accessibilityPermissionDenied
    case couldNotCreateEventTap

    var errorDescription: String? {
        switch self {
        case .accessibilityPermissionDenied:
            "QBlocker needs Accessibility permission before it can listen for Cmd-Q."
        case .couldNotCreateEventTap:
            "QBlocker could not create the keyboard event tap."
        }
    }
}
