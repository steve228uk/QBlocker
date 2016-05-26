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

    private var accessibilityWindowController: NSWindowController?
    private var firstRunWindowController: NSWindowController?
    private lazy var preferencesWindowController: NSWindowController = {
        return NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("preferences window") as! NSWindowController
    }()
    
    class var sharedDelegate: AppDelegate? {
        return NSApplication.sharedApplication().delegate as? AppDelegate
    }
    
    // MARK: - Instantiation
    
    override init() {
        super.init()
        NSUserDefaults.standardUserDefaults().registerDefaults(["accidentalQuits": 0, "firstRunComplete": false, "listMode": 0])
    }
    
    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        setupDevMate()
        
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = [promptFlag: false]
        if AXIsProcessTrustedWithOptions(myDict) {
            do {
                try KeyListener.sharedKeyListener.start()
            } catch {
                NSLog("Could not launch listener")
            }
            
            showFirstRunWindowIfRequired()
            
        } else {
            if let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("accessibility window") as? NSWindowController {
                accessibilityWindowController = windowController
                accessibilityWindowController?.showWindow(self)
                accessibilityWindowController?.window?.makeKeyAndOrderFront(self)
            }
        }
        
    }
    
    // MARK: - Actions
    
    /**
     Show the first run screen if the NSUserDefault stating it has already be run isn't set
     */
    func showFirstRunWindowIfRequired() {
        guard !NSUserDefaults.standardUserDefaults().boolForKey("firstRunComplete") else {
            return
        }
        
        if let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("first run window") as? NSWindowController {
            firstRunWindowController = windowController
            firstRunWindowController?.showWindow(self)
            firstRunWindowController?.window?.makeKeyAndOrderFront(self)
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstRunComplete")
        }
    }
    
    /**
     Bring the app into foreground and show the preferences window
     */
    func showPreferencesWindow() {
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        self.preferencesWindowController.showWindow(nil)
    }

    /**
     Setup the devmate tracker, issues and updater
     */
    func setupDevMate() {
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        DevMateKit.setupIssuesController(nil, reportingUnhandledIssues: true)
        DM_SUUpdater.sharedUpdater().automaticallyChecksForUpdates = true
        DM_SUUpdater.sharedUpdater().automaticallyDownloadsUpdates = true
    }

}

