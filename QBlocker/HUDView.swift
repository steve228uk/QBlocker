//
//  HUDView.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Cocoa

class HUDView: NSView {

	@IBOutlet var textLabel: NSTextField!
	
	override func awakeFromNib() {
		
		super.awakeFromNib()

		wantsLayer = true
		layer?.cornerRadius = 12
	}
	
	override func draw(_ dirtyRect: NSRect) {
	
		super.draw(dirtyRect)
		
		NSColor.controlTextColor.setFill()
		__NSRectFill(dirtyRect)
	}
}
