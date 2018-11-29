//
//  ExcludeViewController + NSTableViewDelegate.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

extension ExcludeViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "app name cell"), owner: nil) as? NSTableCellView else {
                return nil
        }
        
        cell.textField?.stringValue = KeyListener.shared.list[row].name
        return cell
    }
    
}
