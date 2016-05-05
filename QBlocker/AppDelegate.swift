//
//  AppDelegate.swift
//  QBlocker
//
//  Created by Stephen Radford on 01/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var accessibilityWindowController: NSWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        setupDevMate()
        
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = [promptFlag: false]
        if AXIsProcessTrustedWithOptions(myDict) {
            do {
                try KeyListener.sharedKeyListener.start()
            } catch {
                print(error)
            }
        } else {
            if let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("accessibility window") as? NSWindowController {
                accessibilityWindowController = windowController
                accessibilityWindowController?.showWindow(self)
            }
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }
    
    func setupDevMate() {
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        DevMateKit.setupIssuesController(nil, reportingUnhandledIssues: true)
        DM_SUUpdater.sharedUpdater().automaticallyChecksForUpdates = true
        DM_SUUpdater.sharedUpdater().automaticallyDownloadsUpdates = true
    }

}

