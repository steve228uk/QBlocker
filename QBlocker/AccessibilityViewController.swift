//
//  AccessibilityViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 05/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class AccessibilityViewController: NSViewController {

    @IBAction func openPreferences(sender: AnyObject) {
        
        guard let scriptPath = NSBundle.mainBundle().pathForResource("OpenPreferences", ofType: "scpt") else {
            print("Could not find applescript")
            return
        }
        
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptPath]
        task.launch()
        
        // Quit the app
        NSApp.terminate(self)
    }
    
    
    
}
