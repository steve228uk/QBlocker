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
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    /// Reference to the storyboard
    @IBOutlet weak var statusMenu: NSMenu!
    
    override func awakeFromNib() {
        statusMenu.delegate = self
        statusItem.image = NSImage(named: "Menu Bar")
        statusItem.image?.isTemplate = true
        statusItem.menu = statusMenu
    }
    
    // MARK: - Actions
    
    @IBAction func quitItemClicked(_ sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    /**
     Toggle open at login on/off
     
     - parameter sender: The menu item
     */
    @IBAction func openAtLogin(_ sender: NSMenuItem) {
        AtLogin.toggle()
    }
    
    
    @IBAction func showPreferences(_ sender: AnyObject) {
        AppDelegate.sharedDelegate?.showPreferencesWindow()
    }
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        statusMenu.item(at: 0)?.title = String(format: "%d Quits Blocked", arguments: [KeyListener.shared.accidentalQuits])
        statusMenu.item(at: 4)?.state = (AtLogin.enabled) ? .on : .off
    }
    
}
