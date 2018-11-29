//
//  KeyListener.swift
//  QBlocker
//
//  Created by Stephen Radford on 02/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import RealmSwift

private func keyDownCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, ptr: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    
    // If the command key wasn't used we can pass the event on
    let flags = event.flags
    guard flags.contains(.maskCommand) else {
        NSLog("command not clicked")
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    // If the shift key was held down we should ignore the event as it breaks the systemwide logout shortcut
    guard !flags.contains(.maskShift) else {
        NSLog("shift clicked")
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    // If the q key wasn't clicked we can ignore the event too
    guard KeyListener.keyValue(for: event)?.lowercased() == "q" else {
        NSLog("q not clicked")
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    guard KeyListener.shared.canQuit else {
        NSLog("not allowed to quit yet")
        return nil
    }
    
    // get the current active app
    guard let app = NSWorkspace.shared.menuBarOwningApplication else {
        NSLog("could not get menubar owning app")
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    // Check if the current app is in the list
    if let bundleId = app.bundleIdentifier {
        let isIdentifierListed = KeyListener.shared.listedBundleIdentifiers.contains(bundleId)
        NSLog("\(ListMode.selected)")
        if (ListMode.selected == .blacklist && isIdentifierListed) || (ListMode.selected == .whitelist && !isIdentifierListed) {
            NSLog("App is excluded")
            return Unmanaged<CGEvent>.passUnretained(event)
        }
    }
    
    // check that the app has CMD Q enabled
    guard KeyListener.isCmdQActive(for: app) else {
        NSLog("\(app.bundleIdentifier ?? String(describing: app)) does not use cmd+q")
        return nil
    }
    
    if KeyListener.shared.canQuit && KeyListener.shared.tries <= KeyListener.delay {
        NSLog("showing HUD")
        HUDAlert.sharedHUDAlert.showHUD(delayTime: 1)
    }
    
    KeyListener.shared.tries += 1
    if KeyListener.shared.tries > KeyListener.delay {
        NSLog("quit successful")
        KeyListener.shared.tries = 0
        KeyListener.shared.canQuit = false
        HUDAlert.sharedHUDAlert.dismissHUD(fade: false)
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    return nil
}

private func keyUpCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, ptr: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    
    // If the command key wasn't used we can pass the event on
    let flags = event.flags
    guard flags.contains(.maskCommand) else {
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    // If the shift key was held down we should ignore the event as it breaks the systemwide logout shortcut
    guard !flags.contains(.maskShift) else {
        NSLog("shift clicked")
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    // If the q key wasn't clicked we can ignore the event too
    guard KeyListener.keyValue(for: event)?.lowercased() == "q" else {
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    if KeyListener.shared.tries <= KeyListener.delay {
        KeyListener.shared.logAccidentalQuit()
    } else {
        HUDAlert.sharedHUDAlert.dismissHUD()
    }
    
    KeyListener.shared.tries = 0
    KeyListener.shared.canQuit = true
    
    return Unmanaged<CGEvent>.passUnretained(event)
}


class KeyListener {
    
    /// Shared instance of the key listener
    static let shared = KeyListener()
    
    /// How long the Q key needs to be held before you can quit
    static var delay: Int {
        return UserDefaults.standard.integer(forKey: "delay") 
    }
    
    /// Reference to our default Realm
    var realm: Realm?
    
    /// The CGEvent for key down
    var keyDown: CFMachPort?
    
    /// The run loop for key down
    var keyDownRunLoopSource: CFRunLoopSource?
    
    /// The CG event for key up
    var keyUp: CFMachPort?
    
    /// The run loop for key up
    var keyUpRunLoopSource: CFRunLoopSource?
    
    /// The number of "tries" that CMD + Q have been hit.
    /// This is set when a user holds down the CMD + Q shortcut.
    var tries = 0
    
    /// Can quit is marked as false as soon as an app has just quit.
    /// If this is not checked then subsequent apps will continue to quit behind it.
    var canQuit = true
    
    /// The number of accidental quits that have been saved by QBlocker
    var accidentalQuits: Int {
        return UserDefaults.standard.integer(forKey: "accidentalQuits")
    }
    
    /// Array of apps to be ignored/allowed (depending on the setting) by QBlocker
    var list: Results<App>? {
        return realm?.objects(App.self).sorted(byKeyPath: "name")
    }
    
    /// The bundle identifiers of all apps from list
    var listedBundleIdentifiers: Set<String> {
        guard let apps = list else {
            return []
        }
        
        return Set(apps.map { $0.bundleID })
    }
    
    init() {
        do {
            realm = try Realm()
        } catch {
            NSLog("Failed to load Realm")
        }
    }
    
    /**
     Start the keyDown and keyUp listeners.
     
     - throws: `KeyListenerError`
     */
    func start() throws {
        
        keyDown = CGEvent.tapCreate(tap: .cghidEventTap,
                                    place: .headInsertEventTap,
                                    options: .defaultTap,
                                    eventsOfInterest: CGEventMask((1 << CGEventType.keyDown.rawValue)),
                                    callback: keyDownCallback,
                                    userInfo:
            Unmanaged.passUnretained(self).toOpaque())
        
        keyUp = CGEvent.tapCreate(tap: .cghidEventTap,
                                  place: .headInsertEventTap,
                                  options: .defaultTap,
                                  eventsOfInterest: CGEventMask((1 << CGEventType.keyUp.rawValue)),
                                  callback: keyUpCallback,
                                  userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        guard keyDown != nil else {
            throw KeyListenerError.AccessibilityPermissionDenied
        }

        keyDownRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyDown, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), keyDownRunLoopSource, CFRunLoopMode.commonModes)
        
        keyUpRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyUp, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), keyUpRunLoopSource, CFRunLoopMode.commonModes)
        
    }
    
    /**
     Store accidental quits in the user defaults
     */
    func logAccidentalQuit() {
        let quits = accidentalQuits + 1
        UserDefaults.standard.set(quits, forKey: "accidentalQuits")
    }
    
    /**
     Checks if CMD+Q is in the menu bar for the current application
     
     - parameter app: The Current App
     */
    class func isCmdQActive(for app: NSRunningApplication) -> Bool {
        
        let app = AXUIElementCreateApplication(app.processIdentifier)
        var menuBar: AnyObject?
        AXUIElementCopyAttributeValue(app, kAXMenuBarAttribute as CFString, &menuBar)
        
        // If we can't get the menubar then exit
        guard menuBar != nil else {
            return false
        }
        
        // Get the toplevel menu items
        let menu = menuBar as! AXUIElement
        var children: AnyObject?
        AXUIElementCopyAttributeValue(menu, kAXChildrenAttribute as CFString, &children)

        guard let items = children as? NSArray, items.count > 0 else {
            return false
        }
        
        // Get the submenus of the first item
        var subMenus: AnyObject?
        let title = items[1] as! AXUIElement // subscript 0 is the apple menu
        AXUIElementCopyAttributeValue(title, kAXChildrenAttribute as CFString, &subMenus)
        
        guard let menus = subMenus as? NSArray, menus.count > 0 else {
            return false
        }
        
        // Get the entries of the submenu
        var entries: AnyObject?
        let submenu = menus[0] as! AXUIElement
        AXUIElementCopyAttributeValue(submenu, kAXChildrenAttribute as CFString, &entries)
        
        guard let menuItems = entries as? NSArray, menuItems.count > 0 else {
            return false
        }
        
        // Loop through the menu items and check if CMD + Q is the shortcut
        for item in menuItems {
            var cmdChar: AnyObject?
            AXUIElementCopyAttributeValue(item as! AXUIElement, kAXMenuItemCmdCharAttribute as CFString, &cmdChar)
            if let char = cmdChar as? String, char == "Q" {
                return true
            }
        }
        
        return false
    }
    
    /**
     Return the key character
     
     - parameter event: They keyboard event
     
     - returns: The characters clicked
     */
    class func keyValue(for event: CGEvent) -> String? {
        return NSEvent(cgEvent: event)?.charactersIgnoringModifiers
    }    
}
