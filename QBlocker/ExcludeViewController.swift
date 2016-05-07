//
//  ExcludeViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class ExcludeViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    // MARK: - Actions
    
    @IBAction func addClicked(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.title = "Choose a .app"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["app"]
        panel.beginSheetModalForWindow(view.window!) { response in
            if (response == NSFileHandlingPanelOKButton) {
                print("yay!")
            }
        }
    }
    
    @IBAction func removeClicked(sender: AnyObject) {
    }
    
}
