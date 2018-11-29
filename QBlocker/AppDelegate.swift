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

    private var accessibilityWindowController: AccessibilityWindowController?
    private var firstRunWindowController: NSWindowController?
    private lazy var preferencesWindowController: NSWindowController = {
        return NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "preferences window") as! NSWindowController
    }()
    
    class var sharedDelegate: AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }
    
    // MARK: - Instantiation
    
    override init() {
        super.init()
        UserDefaults.standard.register(defaults: [
            "accidentalQuits": 0,
            "firstRunComplete": false,
            "listMode": ListMode.blacklist.rawValue,
            "delay": 4
        ])
    }
    
    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        setupDevMate()
        
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue()
        let myDict = [promptFlag: false] as CFDictionary
        if AXIsProcessTrustedWithOptions(myDict) {
            do {
                try KeyListener.shared.start()
            } catch {
                print("Could not launch listener")
            }
            
            showFirstRunWindowIfRequired()
            
        } else {
            if let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "accessibility window") as? AccessibilityWindowController {
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
        guard !UserDefaults.standard.bool(forKey: "firstRunComplete") else {
            return
        }
        
        if let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "first run window") as? NSWindowController {
            firstRunWindowController = windowController
            firstRunWindowController?.showWindow(self)
            firstRunWindowController?.window?.makeKeyAndOrderFront(self)
            
            UserDefaults.standard.set(true, forKey: "firstRunComplete")
        }
    }
    
    /**
     Bring the app into foreground and show the preferences window
     */
    func showPreferencesWindow() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        preferencesWindowController.showWindow(nil)
    }

    /**
     Setup the devmate tracker, issues and updater
     */
    func setupDevMate() {
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        DevMateKit.setupIssuesController(nil, reportingUnhandledIssues: true)
        DM_SUUpdater.shared().automaticallyChecksForUpdates = true
        DM_SUUpdater.shared().automaticallyDownloadsUpdates = true
    }

}

