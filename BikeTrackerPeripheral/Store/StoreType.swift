//
//  StoreType.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 04/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation

// Light weight implementation of Redux kind of State and Store. To enforce
// convention, the implementation enforces reducer as a static function on the State itself instead
// of a free function.
public protocol StateType {
    associatedtype Action

    // To ensure initial default value, different states may have
    // custom init function if required.
    init()

    static func reducer(_ action: Action, _ state: Self) -> Self
}

public protocol StoreType: AnyObject {
    associatedtype State: StateType

    var state: State { get }

    func dispatch(_ action: State.Action)
}
