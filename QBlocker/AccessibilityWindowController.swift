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

        window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.popUpMenuWindow)))
        window?.titlebarAppearsTransparent = true
        window?.backgroundColor = NSColor(calibratedHue:0.00, saturation:0.00, brightness:0.90, alpha:1.00)
    }
    
}
