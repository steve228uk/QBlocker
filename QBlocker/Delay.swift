//
//  Delay.swift
//  QBlocker
//
//  http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
//

import Foundation

typealias dispatch_cancelable_closure = (_ cancel : Bool) -> Void
typealias DispatchBlock = () -> Void

func delay(time:TimeInterval, closure:@escaping ()->Void) ->  dispatch_cancelable_closure? {
    
    func dispatch_later(clsr:@escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time * Double(NSEC_PER_SEC), execute: clsr)
    }

    var closure:DispatchBlock? = closure
    var cancelableClosure:dispatch_cancelable_closure?
    
    let delayedClosure:dispatch_cancelable_closure = { cancel in
        if closure != nil {
            if (cancel == false) {
                DispatchQueue.main.async(execute: closure!)
            }
        }
        closure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(false)
        }
    }
    
    return cancelableClosure;
}

func cancel_delay(closure:dispatch_cancelable_closure?) {
    
    if closure != nil {
        closure!(true)
    }
}
