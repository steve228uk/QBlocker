//
//  AccessibilityView.swift
//  QBlocker
//
//  Created by Tomohiro Kumagai on 11/29/30 H.
//  Copyright © 30 Heisei Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class AccessibilityView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let path = NSBezierPath()
        
        NSColor.windowBackgroundColor.setFill()
        
        path.appendRect(dirtyRect)
        path.fill()
    }
    
}
