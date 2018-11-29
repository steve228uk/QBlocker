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
    
    @IBAction func addClicked(_ sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.title = "Choose a .app"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["app"]
        panel.beginSheetModal(for: view.window!) { response in
            if (response == .OK) {
                for url in panel.urls {
					
					guard let bundle = Bundle(url: url)?.bundleIdentifier else {
                        continue
                    }
                    
                    let name = FileManager.default.displayName(atPath: url.path)
                    
                    let app = App()
                    app.name = name
                    app.bundleID = bundle
					KeyListener.shared.add(excludedApp: app)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func removeClicked(_ sender: AnyObject) {
        guard tableView.selectedRowIndexes.count > 0 else {
                print("Nothing selected")
                return
            }
        
		tableView.selectedRowIndexes
			.map { index in KeyListener.shared.list[index] }
			.forEach { app in KeyListener.shared.remove(excludedApp: app) }
		
        tableView.reloadData()
    }
    
}
