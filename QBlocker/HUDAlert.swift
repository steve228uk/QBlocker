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
    
    /// The dispatch delay that can be cancelled if the HUD is displayed again during that time
    var delayer: dispatch_cancelable_closure?
    
    init() {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 426, 79), styleMask: .borderless, backing: .buffered, defer: false)
        window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)))
        window?.isOpaque = false
        window?.backgroundColor = NSColor.clear

        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "Alert")
        window?.contentView? = (vc as AnyObject).view
        window?.contentView?.wantsLayer = true
    
        window?.makeKey()
    }
    
    /**
     Show the HUD window
     */
    func showHUD(delayTime: TimeInterval? = nil) {
        
        guard let screenRect = NSScreen.main?.visibleFrame else {
            print("Could not get screen frame")
            return
        }
    
        cancel_delay(closure: delayer)
        
        let newRect = NSMakeRect((screenRect.size.width - 426) * 0.5, (screenRect.size.height - 79) * 0.5, 426, 79)
        window?.setFrame(newRect, display: true)
        window?.makeKeyAndOrderFront(self)
        
        if let delayTime = delayTime {
            delayer = delay(time: delayTime) {
                self.dismissHUD()
            }
        }
    }
    
    /**
     Dismiss the HUD window
     */
    func dismissHUD(fade: Bool = true) {
        
        guard fade else {
            self.window?.orderOut(self)
            return
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            self.window?.contentView?.animator().alphaValue = 0
        }) {
            self.window?.orderOut(self)
            self.window?.contentView?.alphaValue = 1
        }
        
    }
    
}
