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
    func addExcludedApp(app: App) {
        do {
            try realm?.write {
                realm?.add(app)
            }
        } catch {
            print("Could not write excluded app")
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
            print("Could not remove excluded app")
        }
    }
    
}