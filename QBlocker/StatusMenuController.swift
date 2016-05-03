//
//  StatusMenuController.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    override func awakeFromNib() {
        statusItem.image = NSImage(named: "Menu Bar")
        statusItem.menu = statusMenu
    }
    
    // MARK: - Actions
    
    @IBAction func quitItemClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
