//
//  FirstRunViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class FirstRunViewController: NSViewController {
    
    @IBAction func dismissWindow(_ sender: AnyObject) {
        view.window?.orderOut(self)
    }
    
    @IBAction func showExcludeApps(_ sender: AnyObject) {
        AppDelegate.sharedDelegate?.showPreferencesWindow()
        view.window?.orderOut(self)
    }
    
}
