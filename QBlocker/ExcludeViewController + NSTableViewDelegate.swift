//
//  ExcludeViewController + NSTableViewDelegate.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

extension ExcludeViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = tableView.makeViewWithIdentifier("app name cell", owner: nil) as? NSTableCellView,
            let app = KeyListener.sharedKeyListener.list?[row] else {
                return nil
        }
        
        cell.textField?.stringValue = app.name
        return cell
    }
    
}