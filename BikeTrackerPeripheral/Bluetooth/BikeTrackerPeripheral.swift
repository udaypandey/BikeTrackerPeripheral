//
//  BikeTrackerPeripheral.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 04/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BikeTrackerPeripheralDelegate: AnyObject {
    func trackerPeripheralDidChange(_ tracker: BikeTrackerPeripheral)

    func trackerPeripheral(_ tracker: BikeTrackerPeripheral, eventDidOccur: String)
}

class BikeTrackerPeripheral: NSObject, CBPeripheralManagerDelegate {
    let bikeTracker = BikeTracker()
    private let peripheralManger: CBPeripheralManager
    
    private var sendMessageFailed = false
    
    weak var delegate: BikeTrackerPeripheralDelegate?
    
    override init() {
        peripheralManger = CBPeripheralManager()
        
        super.init()
        bikeTracker.bikeTrackerPeripheral = self
        peripheralManger.delegate = self
    }
    
    private func startAdvertising() {
        let advertisement = bikeTracker.advertisement()

        DebugLogger.info("startAdvertising: \(advertisement)")
        peripheralManger.startAdvertising(advertisement)
    }
    
    private func stopAdvertising() {
        peripheralManger.stopAdvertising()
    }

    private func addService() {
        let service = bikeTracker.service
        peripheralManger.add(service)
    }
    
    private func handleIncomingRequest(_ peripheral: CBPeripheralManager, request: CBATTRequest) {
        guard let response = bikeTracker.handleIncomingChangeRequest(request: request) else { return }
        
        peripheral.updateValue(response,
                               for: bikeTracker.responseCharacteristic,
                               onSubscribedCentrals: nil)
    }
    
    private func handleIncomingReadRequest(_ peripheral: CBPeripheralManager, request: CBATTRequest) {
        guard let response = bikeTracker.handleIncomingReadRequest(request: request) else { return }
        
        peripheral.updateValue(response,
                               for: bikeTracker.trackerStateCharacteristic,
                               onSubscribedCentrals: nil)
    }
    
    func updateTrackerState() {
        let trackerStateValue = bikeTracker.trackerStateValue
        if peripheralManger.updateValue(trackerStateValue!,
                               for: bikeTracker.trackerStateCharacteristic,
                               onSubscribedCentrals: nil) == false {
            sendMessageFailed = true
        }
    }
}

extension BikeTrackerPeripheral {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        DebugLogger.info("peripheralManagerDidUpdateState: ")
        
        delegate?.trackerPeripheral(self, eventDidOccur: "peripheralManagerDidUpdateState:")
        
        switch peripheral.state {
        case .poweredOn:
            addService()
        default:
            DebugLogger.info("peripheralManagerDidUpdateState: Device not ready")
            break
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        DebugLogger.info("peripheralManagerDidStartAdvertising: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "peripheralManagerDidStartAdvertising:")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        DebugLogger.info("didAddService: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "didAddService:")

        startAdvertising()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        DebugLogger.info("didSubscribeToCharacteristic: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "didSubscribeToCharacteristic:")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        DebugLogger.info("didUnsubscribeFromCharacteristic: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "didUnsubscribeFromCharacteristic:")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        DebugLogger.info("didReceiveReadRequest: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "didReceiveReadRequest:")

        handleIncomingReadRequest(peripheral, request: request)
        peripheral.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        DebugLogger.info("didReceiveWrite: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "didReceiveWrite:")

        for request in requests {
            handleIncomingRequest(peripheral, request: request)
            peripheral.respond(to: request, withResult: .success)
        }
        
        delegate?.trackerPeripheralDidChange(self)
        updateTrackerState()
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        DebugLogger.info("peripheralManagerIsReady: ")
        delegate?.trackerPeripheral(self, eventDidOccur: "peripheralManagerIsReady:")

        if sendMessageFailed == true {
            sendMessageFailed = false
            updateTrackerState()
        }
    }
}
