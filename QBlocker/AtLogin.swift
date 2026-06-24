//
//  AtLogin.swift
//  QBlocker
//
//  Created by Stephen Radford on 04/05/2016.
//  Modernized for ServiceManagement.
//

import Foundation
import ServiceManagement

enum AtLogin {
    static var enabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else if SMAppService.mainApp.status == .enabled {
            try SMAppService.mainApp.unregister()
        }
    }

    static func toggle() throws {
        try setEnabled(!enabled)
    }
}
