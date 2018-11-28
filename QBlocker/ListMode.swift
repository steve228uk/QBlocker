//
//  ListMode.swift
//  QBlocker
//
//  Created by Florian Schliep on 25.05.16.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

enum ListMode: Int {
    case Blacklist = 0
    case Whitelist = 1
    
    static var selectedMode: ListMode {
        return ListMode(rawValue: UserDefaults.standard.integer(forKey: "listMode")) ?? .Whitelist
    }
    
    func select() {
        UserDefaults.standard.set(self.rawValue, forKey: "listMode")
    }
}
