//
//  Store.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 04/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation

class Store<State: StateType>: StoreType {
    private(set) public var state: State

    init(state: State = State()) {
        self.state = state
    }

    func dispatch(_ action: State.Action) {
        let newState = type(of: state).reducer(action, state)
        state = newState
    }
}
