//
//  State.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 04/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BikeTrackerState: Codable {
    var state = DeviceState.online
    var lightState = LightState.off
    var sirenState = SirenState.off
    var armedState = ArmedState.disarmed
    var lightBattery: Double = 90.0
    var trackerBattery: Double = 70.0

}

extension BikeTrackerState {
    static var unknown: BikeTrackerState {
        return BikeTrackerState(state: .offline,
                                lightState: .off,
                                armedState: .disarmed,
                                lightBattery: 0,
                                trackerBattery: 0)
    }
}

extension BikeTrackerState {
    enum Action {
        case trackerState(_ trackerState: BikeTrackerState)
        case state(_ state: DeviceState)
        case sirenState(_ sirenState: SirenState)
        case lightState(_ lightState: LightState)
        case armedState(_ armedState: ArmedState)
        case lightBattery(_ battery: Double)
        case trackerBattery(_ battery: Double)

    }
}

extension BikeTrackerState: StateType {
    static func reducer(_ action: Action,
                        _ state: BikeTrackerState) -> BikeTrackerState {
        var newState = state

        switch action {
        case .trackerState(let trackerState):
            newState = trackerState
            
        case .state(let state):
            newState.state = state
        case .sirenState(let sirenState):
            newState.sirenState = sirenState
        case .lightState(let lightState):
            newState.lightState = lightState
        case .armedState(let armedState):
            newState.armedState = armedState
        case .lightBattery(let battery):
            newState.lightBattery = battery
        case .trackerBattery(let battery):
            newState.trackerBattery = battery
        }

        return newState
    }
}

extension BikeTrackerState {
    enum DeviceState: String, Codable {
        case online, offline, inactive
    }
    
    enum LightState: String, Codable {
        case on, off
    }
    
    enum ArmedState: String, Codable {
        case armed, disarmed
    }

    enum SirenState: String, Codable {
        case on, off
    }

    enum UUID: String {
        case trackerState            = "7C807DA2-BA20-404B-B3B0-BAE02F506C98"
        
        case request                 = "CD671E4E-232D-4EF2-A1D6-D0B1C6A9CEDA"
        case response                = "CCD3D31F-ECDB-4C67-9B8F-144114E0C966"

        case service                 = "C128EFAC-7DEC-4B58-9606-59A5F489AEDC"

        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
}

extension BikeTrackerState {
    enum Request: String {
        case arm
        case disarm
        
        case lightsOn
        case lightsOff
        
        case chirp
        
        case sirenOn
        case sirenOff
    }
}
