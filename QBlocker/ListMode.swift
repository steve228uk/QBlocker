//
//  ListMode.swift
//  QBlocker
//
//  Created by Florian Schliep on 25.05.16.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

enum ListMode: Int {
    case Whitelist = 0
    case Blacklist = 1
    
    static var selectedMode: ListMode {
        return ListMode(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("listMode")) ?? .Whitelist
    }
    
    func select() {
        NSUserDefaults.standardUserDefaults().setInteger(self.rawValue, forKey: "listMode")
    }
    
    var localizedDescription: String {
        switch self {
        case .Whitelist:
            return "Whitelist"
        case .Blacklist:
            return "Blacklist"
        }
    }
}
