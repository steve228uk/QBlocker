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
        
		tabBarLocation = .top
        
		tabBar.material = .titlebar
        tabBar.blendingMode = .withinWindow
        tabBar.translucent = true
        
    }
    
}
