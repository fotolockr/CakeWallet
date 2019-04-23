import Foundation
import RxSwift



struct AsyncRxCommand<Payload>: Command {
    typealias Handler = (Payload, @escaping () -> Void) -> Void
    
    var isExecute: Observable<Bool> {
        return _isExecute.asObservable()
    }
    
    private let _isExecute: Variable<Bool>
    private let handler: Handler
    
    init(handler: @escaping Handler) {
        _isExecute = Variable(false)
        self.handler = handler
    }
    
    func execute(withPayload payload: Payload) {
        _isExecute.value = true
        handler(payload) {
            self._isExecute.value = false
        }
    }
}

struct RxCommand<Payload>: Command {
    typealias Handler = (Payload) -> Void
    
    var isExecute: Observable<Bool> {
        return _isExecute.asObservable()
    }
    
    private let _isExecute: Variable<Bool>
    private let handler: Handler
    
    init(handler: @escaping Handler) {
        _isExecute = Variable(false)
        self.handler = handler
    }
    
    func execute(withPayload payload: Payload) {
        _isExecute.value = true
        handler(payload)
        _isExecute.value = false
    }
}


struct CreateWalletPayload {
    let name: String
    let password: String
}

struct CreateWalletCommand<CreateWalletPayload>: Command {
    var isExecute: Observable<Bool> {
        return _isExecute.asObservable()
    }
    
    private let _isExecute: Variable<Bool>
    
    func executing(withPayload payload: CreateWalletPayload, finished: @escaping () -> Void) {
        finished()
    }
    
    func execute(withPayload payload: CreateWalletPayload) {
        _isExecute.value = false
        executing(withPayload: payload) {
            self._isExecute.value = false
        }
    }
}

let CreateWalletCommand1 = {
    return AsyncRxCommand<CreateWalletPayload> { paylaod, finished in
        finished()
    }
}

/*
 
 1. Navigation flow
 2. UIViewController + View
 3. Commands
 4. Reactive data
 5. Entities
 
 */
