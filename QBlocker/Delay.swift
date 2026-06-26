//
//  Delay.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import Foundation

typealias CancelableDelay = DispatchWorkItem

@discardableResult
func delay(_ seconds: TimeInterval, perform work: @escaping () -> Void) -> CancelableDelay {
    let item = DispatchWorkItem(block: work)
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: item)
    return item
}

func cancelDelay(_ item: CancelableDelay?) {
    item?.cancel()
}
