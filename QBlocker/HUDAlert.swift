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
    static let shared = HUDAlert()
    
    /// The window that will be used to display the HUD alert
    var window: NSWindow
    
    /// The dispatch delay that can be cancelled if the HUD is displayed again during that time
    var delayer: DispatchCancelableClosure?
    
    init() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 426, height: 79), styleMask: .borderless, backing: .buffered, defer: false)
        window.level = NSWindow.Level(.assistiveTechHighWindow)
        window.isOpaque = false
        window.backgroundColor = .clear

        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "Alert") as! NSViewController
        window.contentView? = vc.view
        window.contentView?.wantsLayer = true
    
        window.makeKey()
    }
    
    /**
     Show the HUD window
     */
    func showHUD(delayTime: TimeInterval? = nil) {
        
        guard let screenRect = NSScreen.main?.visibleFrame else {
            print("Could not get screen frame")
            return
        }
    
        cancelDelay(closure: delayer)
        
        let newRect = NSRect(x: (screenRect.size.width - 426) * 0.5, y: (screenRect.size.height - 79) * 0.5, width: 426, height: 79)
        window.setFrame(newRect, display: true)
        window.makeKeyAndOrderFront(self)
        
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
            window.orderOut(self)
            return
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            window.contentView?.animator().alphaValue = 0
        }) {
            self.window.orderOut(self)
            self.window.contentView?.alphaValue = 1
        }
        
    }
    
}
