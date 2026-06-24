//
//  KeyListenerError.swift
//  QBlocker
//
//  Created by Stephen Radford on 02/05/2016.
//  Modernized for SwiftUI.
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
