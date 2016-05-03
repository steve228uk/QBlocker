//
//  KeyListener.swift
//  QBlocker
//
//  Created by Stephen Radford on 02/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Foundation

private func keyDownCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, ptr: UnsafeMutablePointer<Void>) -> Unmanaged<CGEvent>? {

    // If the command key wasn't used we can pass the event on
    let flags = CGEventGetFlags(event)
    guard (flags.rawValue & CGEventFlags.MaskCommand.rawValue) != 0 else {
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    // If the q key wasn't clicked we can ignore the event too
    guard CGEventGetIntegerValueField(event, .KeyboardEventKeycode) == 12 else {
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    
    KeyListener.sharedKeyListener.tries += 1
    if KeyListener.sharedKeyListener.tries > 5 && KeyListener.sharedKeyListener.canQuit {
        KeyListener.sharedKeyListener.tries = 0
        KeyListener.sharedKeyListener.canQuit = false
        return Unmanaged<CGEvent>.passUnretained(event)
    }
    
    return nil
}

private func keyUpCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, ptr: UnsafeMutablePointer<Void>) -> Unmanaged<CGEvent>? {
    
    KeyListener.sharedKeyListener.tries = 0
    KeyListener.sharedKeyListener.canQuit = true
    
    return Unmanaged<CGEvent>.passUnretained(event)
}


class KeyListener {
    
    /// Shared instance of the key listener
    static let sharedKeyListener = KeyListener()
    
    /// The CGEvent for key down
    var keyDown: CFMachPort?
    
    /// The run loop for key down
    var keyDownRunLoopSource: CFRunLoopSource?
    
    /// The CG event for key up
    var keyUp: CFMachPort?
    
    /// The run loop for key up
    var keyUpRunLoopSource: CFRunLoopSource?
    
    /// The number of "tries" that CMD + Q have been hit.
    /// This is set when a user holds down the CMD + Q shortcut.
    var tries = 0
    
    /// Can quit is marked as false as soon as an app has just quit.
    /// If this is not checked then subsequent apps will continue to quit behind it.
    var canQuit = true
    
    func start() {
        
        keyDown = CGEventTapCreate(CGEventTapLocation.CGHIDEventTap,
                                CGEventTapPlacement.HeadInsertEventTap,
                                CGEventTapOptions.Default,
                                CGEventMask((1 << CGEventType.KeyDown.rawValue)),
                                keyDownCallback, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque()))
        
        keyUp = CGEventTapCreate(CGEventTapLocation.CGHIDEventTap,
                                   CGEventTapPlacement.HeadInsertEventTap,
                                   CGEventTapOptions.Default,
                                   CGEventMask((1 << CGEventType.KeyUp.rawValue)),
                                   keyUpCallback, UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque()))
        
        if (keyDown != nil)
        {
            print("running")
            
            keyDownRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyDown, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), keyDownRunLoopSource, kCFRunLoopCommonModes)
            
            keyUpRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyUp, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), keyUpRunLoopSource, kCFRunLoopCommonModes)
            
        }else
        {
            //todo: throw?
            print("Fail CGEventTapCreate")
            exit(1)
        }
        
    }
    
}