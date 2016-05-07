//
//  FirstRunViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class FirstRunViewController: NSViewController {
    
    @IBAction func dismissWindow(sender: AnyObject) {
        view.window?.orderOut(self)
    }
    
}
