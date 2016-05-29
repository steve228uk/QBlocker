//
//  TabBarController.swift
//  QBlocker
//
//  Created by Stephen Radford on 29/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import SRTabBarController

class TabBarController: SRTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarLocation = .Top
        
        tabBar?.material = .Titlebar
        tabBar?.blendingMode = .WithinWindow
        tabBar?.translucent = true
        
    }
    
}
