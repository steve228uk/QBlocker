//
//  AccessibilityWindowController.swift
//  QBlocker
//
//  Created by Stephen Radford on 05/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class AccessibilityWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.level = NSWindow.Level(.popUpMenuWindow)
        window?.titlebarAppearsTransparent = true
    }
}
