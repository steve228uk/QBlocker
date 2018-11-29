//
//  HUDView.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class HUDView: NSView {

	override func awakeFromNib() {
		
		super.awakeFromNib()
		
		wantsLayer = true

		layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
		layer?.cornerRadius = 12
	}
}
