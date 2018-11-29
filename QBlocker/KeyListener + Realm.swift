//
//  KeyListener + Realm.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import RealmSwift

extension KeyListener {
    
    /**
     Add an excluded app to the Realm
     
     - parameter app: The app to be added
     */
    func add(excludedApp app: App) {
        do {
            try realm?.write {
                realm?.add(app, update: true)
            }
        } catch {
            NSLog("Could not write excluded app")
        }
    }
    
    /**
     Remove an app from the Realm
     
     - parameter app: The app to be removed
     */
    func removeExcludedApp(app: App) {
        do {
            try realm?.write {
                realm?.delete(app)
            }
        } catch {
            NSLog("Could not remove excluded app")
        }
    }
    
}
