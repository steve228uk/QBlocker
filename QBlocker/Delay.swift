//
//  Delay.swift
//  QBlocker
//
//  Created by Stephen Radford on 07/05/2016.
//  Modernized for Swift concurrency-era APIs.
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
