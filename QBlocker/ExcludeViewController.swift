//
//  ExcludeViewController.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import RealmSwift

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
                for url in panel.URLs {
                    guard let bundle = NSBundle(URL: url)?.bundleIdentifier, path = url.path else {
                        continue
                    }
                    
                    let name = NSFileManager.defaultManager().displayNameAtPath(path)
                    
                    let app = App()
                    app.name = name
                    app.bundleID = bundle
                    KeyListener.sharedKeyListener.addExcludedApp(app)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func removeClicked(sender: AnyObject) {
        guard tableView.selectedRowIndexes.count > 0,
            let apps = KeyListener.sharedKeyListener.list else {
                print("Nothing selected")
                return
            }
        
        var toRemove = [App]()
        tableView.selectedRowIndexes.enumerateIndexesUsingBlock { index, stop in
            toRemove.append(apps[index])
        }
        
        for app in toRemove {
            KeyListener.sharedKeyListener.removeExcludedApp(app)
        }
        
        tableView.reloadData()
    }
    
}
