//
//  App.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import RealmSwift

class App: Object {
    
    /// The name of the app that will be displayed as a label
    @objc dynamic var name = ""
    
    /// The bundle ID of the app. e.g. uk.co.wearecocoon.QBlocker
    @objc dynamic var bundleID = ""
    
    override static func primaryKey() -> String? {
        return "bundleID"
    }
    
}
