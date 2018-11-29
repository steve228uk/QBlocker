//
//  AtLogin.swift
//  QBlocker
//
//  Created by Stephen Radford on 04/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import CoreServices

/**
 *  Handle the launch at login settings for the app
 */
struct AtLogin {
    
    /// Whether launch at login is enabled or not
    static var enabled: Bool {
        
        return launchItem != nil
    }
    
    /// The launch item that's stored in LSSharedFileList
    private static var launchItem: LSSharedFileListItem? {
        let appUrl = URL(fileURLWithPath: Bundle.main.bundlePath)
        
        guard let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil) else {
            return nil
        }
        
        let loginItems = LSSharedFileListCopySnapshot(loginItemsRef.takeRetainedValue(), nil).takeRetainedValue()
        for item in loginItems as NSArray {
            
            // Ensure that the item is a LSSharedFileListItem
            guard CFGetTypeID(item as CFTypeRef) == LSSharedFileListItemGetTypeID() else {
                continue
            }
            
            var error: Unmanaged<CFError>?
            let itemUrl = LSSharedFileListItemCopyResolvedURL((item as! LSSharedFileListItem), 0, &error).takeRetainedValue() as URL
            
            if itemUrl == appUrl {
                return (item as! LSSharedFileListItem)
            }
            
        }
        
        return nil
    }
    
    /**
     Toggle launch at login
     */
    static func toggle() {
        
        guard let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil) else {
            return
        }
        
        if enabled { // remove it from the startup
            LSSharedFileListItemRemove(loginItems.takeRetainedValue(), launchItem)
        } else { // add it to the startup
            let appUrl = URL(fileURLWithPath: Bundle.main.bundlePath)
            LSSharedFileListInsertItemURL(loginItems.takeRetainedValue(), kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, appUrl as CFURL, nil, nil)
        }
        
    }
    
}
