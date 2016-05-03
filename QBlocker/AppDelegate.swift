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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = [promptFlag: true]
        if AXIsProcessTrustedWithOptions(myDict) {
            do {
                try KeyListener.sharedKeyListener.start()
            } catch {
                print(error)
            }
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }

}

