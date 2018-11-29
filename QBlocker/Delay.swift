//
//  Delay.swift
//  QBlocker
//
//  http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
//

import Foundation

typealias DispatchCancelableClosure = (_ cancel : Bool) -> Void
typealias DispatchBlock = () -> Void

func delay(time:TimeInterval, closure:@escaping DispatchBlock) ->  DispatchCancelableClosure? {
    
    func dispatchLater(clsr:@escaping DispatchBlock) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: clsr)
    }

    var closure:DispatchBlock? = closure
    var cancelableClosure:DispatchCancelableClosure?
    
    let delayedClosure:DispatchCancelableClosure = { cancel in
        if closure != nil {
            if (cancel == false) {
                DispatchQueue.main.async(execute: closure!)
            }
        }
        closure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatchLater {
        if let delayedClosure = cancelableClosure {
            delayedClosure(false)
        }
    }
    
    return cancelableClosure;
}

func cancelDelay(closure:DispatchCancelableClosure?) {
    
    if closure != nil {
        closure!(true)
    }
}
