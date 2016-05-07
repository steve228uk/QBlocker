//
//  Delay.swift
//  QBlocker
//
//  http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
//

import Foundation

typealias dispatch_cancelable_closure = (cancel : Bool) -> Void

func delay(time:NSTimeInterval, closure:()->Void) ->  dispatch_cancelable_closure? {
    
    func dispatch_later(clsr:()->Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(time * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), clsr)
    }
    
    var closure:dispatch_block_t? = closure
    var cancelableClosure:dispatch_cancelable_closure?
    
    let delayedClosure:dispatch_cancelable_closure = { cancel in
        if closure != nil {
            if (cancel == false) {
                dispatch_async(dispatch_get_main_queue(), closure!);
            }
        }
        closure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(cancel: false)
        }
    }
    
    return cancelableClosure;
}

func cancel_delay(closure:dispatch_cancelable_closure?) {
    
    if closure != nil {
        closure!(cancel: true)
    }
}