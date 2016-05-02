//
//  KeyListener.swift
//  QBlocker
//
//  Created by Stephen Radford on 02/05/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Foundation

private func keyDownCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, ptr: UnsafeMutablePointer<Void>) -> Unmanaged<CGEvent>?
{

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

private func keyUpCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, ptr: UnsafeMutablePointer<Void>) -> Unmanaged<CGEvent>?
{
    
    KeyListener.sharedKeyListener.tries = 0
    KeyListener.sharedKeyListener.canQuit = true
    
    return Unmanaged<CGEvent>.passUnretained(event)
}

class KeyListener {
    
    /// Shared instance of the key listener
    static let sharedKeyListener = KeyListener()
    
    var keyDown: CFMachPort?
    
    var keyDownRunLoopSource: CFRunLoopSource?
    
    var keyUp: CFMachPort?
    
    var keyUpRunLoopSource: CFRunLoopSource?
    
    var tries = 0
    
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