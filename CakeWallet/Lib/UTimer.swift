//
//  UTimer.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation

final class UTimer {
    var listener: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    private let timer: DispatchSourceTimer
    private var state: State = .suspended
    
    init(deadline deadlineTime: DispatchTime, repeating repeatingTime: DispatchTimeInterval,
         queue: DispatchQueue? = nil,  eventHandler: (() -> Void)?) {
        self.listener = eventHandler
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: deadlineTime, repeating: repeatingTime)
        timer.setEventHandler(handler: { [weak self] in
            self?.listener?()
        })
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume()
        listener = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
