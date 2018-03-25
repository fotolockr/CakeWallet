//
//  UTimer.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

final class UTimer {
    var listener: (() -> Void)? {
        didSet {
            timer.setEventHandler { [weak self] in
                self?.listener?()
            }
        }
    }
    
    private enum State {
        case suspended
        case resumed
    }
    
    private let timer: DispatchSourceTimer
    private var state: State = .suspended
    
    init(deadline deadlineTime: DispatchTime, repeating repeatingTime: DispatchTimeInterval,
         queue: DispatchQueue? = nil,  eventHandler: (() -> Void)? = nil) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: deadlineTime, repeating: repeatingTime)
        self.listener = eventHandler
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
