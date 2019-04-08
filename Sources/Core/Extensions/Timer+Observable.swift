//
//  Timer+Observable.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

extension Timer {
    static func schedule(interval: TimeInterval) -> Observable<Void> {
        var shouldInvalidateTimer = false
        let observable = MutableObservable<Void>(value: ()) {
            shouldInvalidateTimer = true
        }
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [observable] timer in
            observable.value = ()
            if shouldInvalidateTimer {
                timer.invalidate()
            }
        }
        return observable
    }
}
