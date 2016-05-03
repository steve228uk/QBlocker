//
//  HUDAlert.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class HUDAlert {
    
    /// Shared instance
    static let sharedHUDAlert = HUDAlert()
    
    /// The window that will be used to display the HUD alert
    var window: NSWindow?
    
    init() {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 426, 79), styleMask: NSBorderlessWindowMask, backing: .Buffered, defer: false)
        window?.level = Int(CGWindowLevelForKey(CGWindowLevelKey.PopUpMenuWindowLevelKey))
        window?.opaque = false
        window?.backgroundColor = NSColor.clearColor()

        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("Alert")
        window?.contentView? = vc.view
        window?.contentView?.wantsLayer = true
        
        window?.makeKeyWindow()
    }
    
    /**
     Show the HUD window
     */
    func showHUD() {
        
        guard let screenRect = NSScreen.mainScreen()?.visibleFrame else {
            print("Could not get screen frame")
            return
        }
    
        let newRect = NSMakeRect((screenRect.size.width - 426) * 0.5, (screenRect.size.height - 79) * 0.5, 426, 79)
        
        window?.setFrame(newRect, display: true)
        window?.makeKeyAndOrderFront(self)
    }
    
    /**
     Dismiss the HUD window
     */
    func dismissHUD() {
        window?.orderOut(self)
    }
    
}