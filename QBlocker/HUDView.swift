//
//  HUDView.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class HUDView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        wantsLayer = true
        layer?.backgroundColor = NSColor(deviceHue: 0, saturation: 0, brightness: 0, alpha: 0.5).cgColor
        layer?.cornerRadius = 12
    }
    
}
