//
//  CocoaSwiftSupport.swift
//  QBlocker
//
//  Created by Tomohiro Kumagai on 2018/11/29.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

extension NSWindow.Level {
	
	init(_ key: CGWindowLevelKey) {
		
		self.init(rawValue: Int(CGWindowLevelForKey(key)))
	}
}
