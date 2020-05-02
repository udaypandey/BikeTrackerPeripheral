//
//  BikeTracker.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 02/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation
import CoreBluetooth
import AVFoundation

class BikeTracker: NSObject {
    let store = Store<BikeTrackerState>()
    
    let trackerStateCharacteristic: CBMutableCharacteristic
    let responseCharacteristic: CBMutableCharacteristic
    let requestCharacteristic: CBMutableCharacteristic

    let service: CBMutableService
    
    let siren = Siren()
    
    unowned var bikeTrackerPeripheral: BikeTrackerPeripheral!
    
    override init() {
        service = CBMutableService(type: BikeTrackerState.UUID.service.uuid, primary: true)

        responseCharacteristic = CBMutableCharacteristic(type: BikeTrackerState.UUID.response.uuid,
                                                         properties: [.notify, .read],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        
        trackerStateCharacteristic = CBMutableCharacteristic(type: BikeTrackerState.UUID.trackerState.uuid,
                                                             properties: [.notify, .read],
                                                             value: nil,
                                                             permissions: [.readable, .writeable])
        
        requestCharacteristic = CBMutableCharacteristic(type: BikeTrackerState.UUID.request.uuid,
                                                 properties: [.write],
                                                 value: nil,
                                                 permissions: [.readable, .writeable])

        var characteristics: [CBMutableCharacteristic] = []
        characteristics.append(trackerStateCharacteristic)
        characteristics.append(requestCharacteristic)
        characteristics.append(responseCharacteristic)

        service.characteristics = characteristics
        
        super.init()
        
        siren.sirenEffect?.delegate = self

    }
}

extension BikeTracker {
    var trackerStateValue: Data? {
        let data = Data.modelData(for: store.state)
        return data?.dataAfterAppendingHeader
    }

    func handleIncomingReadRequest(request: CBATTRequest) -> Data? {
        switch request.characteristic.uuid {
        case BikeTrackerState.UUID.trackerState.uuid:
            let data = Data.modelData(for: store.state)
            return data?.dataAfterAppendingHeader

        default:
            return nil
        }
        
    }

    func handleIncomingChangeRequest(request: CBATTRequest) -> Data? {
        guard request.characteristic.uuid == BikeTrackerState.UUID.request.uuid,
            let data = request.value else {
                DebugLogger.info("Invalid request / data")
                return nil
        }

        let jsonData = data.dataAfterStrippingHeader
        
        guard let jsonRequest = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String] else {
            DebugLogger.info("Received data can't be parsed")
            return nil
        }
        
        guard let requestTypeString = jsonRequest["requestType"],
            let requestType = BikeTrackerState.Request(rawValue: requestTypeString) else {
                return nil
        }

        var dict: [String: Any] = [:]
        dict["type"] = "response"
        dict["responseType"] = requestType.rawValue
        dict["status"] = "SUCCESS"

        switch requestType {
        case .arm:
            store.dispatch(.armedState(.armed))

        case .disarm:
            store.dispatch(.armedState(.disarmed))
            
        case .lightsOn:
            store.dispatch(.lightState(.on))
            toggleTorch(on: true)

        case .lightsOff:
            store.dispatch(.lightState(.off))
            toggleTorch(on: false)

        case .chirp:
            chirp()
            break
            
        case .sirenOn:
            store.dispatch(.sirenState(.on))
            siren.start()
            
        case .sirenOff:
            store.dispatch(.sirenState(.off))
            siren.stop()
        }
        
        guard let responseData = try? JSONSerialization.data(withJSONObject: dict,
                                                             options: .prettyPrinted) else {
            return nil
        }
        
        return responseData.dataAfterAppendingHeader
    }
}

extension BikeTracker {
    func advertisement() -> [String : Any] {
        var advertisement: [String : Any] = [:]
        advertisement[CBAdvertisementDataServiceUUIDsKey] = [BikeTrackerState.UUID.service.uuid]
        advertisement[CBAdvertisementDataLocalNameKey] = "Wiggins Bike Tracker"

        return advertisement
    }
}

extension BikeTracker: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        store.dispatch(.sirenState(.off))
        bikeTrackerPeripheral.updateTrackerState()
        bikeTrackerPeripheral.delegate?.trackerPeripheralDidChange(bikeTrackerPeripheral)
    }
}
