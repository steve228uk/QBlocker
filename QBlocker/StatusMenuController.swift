//
//  StatusMenuController.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import CoreServices

class StatusMenuController: NSObject, NSMenuDelegate {
    
    /// The icon added to the menu bar
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    /// Reference to the storyboard
    @IBOutlet weak var statusMenu: NSMenu!
    
    override func awakeFromNib() {
        statusMenu.delegate = self
        statusItem.image = NSImage(named: "Menu Bar")
        statusItem.image?.template = true
        statusItem.menu = statusMenu
    }
    
    // MARK: - Actions
    
    @IBAction func quitItemClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    /**
     Toggle open at login on/off
     
     - parameter sender: The menu item
     */
    @IBAction func openAtLogin(sender: NSMenuItem) {
        AtLogin.toggle()
    }
    
    
    @IBAction func showPreferences(sender: AnyObject) {
        AppDelegate.sharedDelegate?.showPreferencesWindow()
    }
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {
        statusMenu.itemAtIndex(0)?.title = (KeyListener.sharedKeyListener.accidentalQuits != 1 ?
            String(format: NSLocalizedString("%d Quits Blocked", comment: ""), arguments: [KeyListener.sharedKeyListener.accidentalQuits]) :
            NSLocalizedString("1 Quit Blocked", comment: ""))
        statusMenu.itemAtIndex(4)?.state = (AtLogin.enabled) ? 1 : 0
    }
    
}
