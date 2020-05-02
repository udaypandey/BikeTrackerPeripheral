//
//  ViewController.swift
//  BikeTracker
//
//  Created by Uday Pandey on 02/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    let bikeTrackerPeripheral =  BikeTrackerPeripheral()

    @IBOutlet weak var deviceDetailedStatus: UILabel!
    @IBOutlet weak var deviceStatus: UILabel!
    
    @IBOutlet weak var signalStatus: StatusView!
    @IBOutlet weak var sirenStatus: StatusView!
    @IBOutlet weak var trackerStatus: BatteryStatusView!
    @IBOutlet weak var lightStatus: BatteryStatusView!
    
    var tracker: BikeTracker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracker = bikeTrackerPeripheral.bikeTracker
        
        navigationItem.title = "Bike Tracker Peripheral"
        
        bikeTrackerPeripheral.delegate = self
        lightStatus.delegate = self
        trackerStatus.delegate = self
        
        oneTimeUpdate()
        update()
    }
    
    private func oneTimeUpdate() {
        lightStatus.title.text = "Lights"
        trackerStatus.title.text = "Tracker"
        sirenStatus.title.text = "Siren"
        signalStatus.title.text = "Signal"
        signalStatus.rightLabel.text = ""
        sirenStatus.detailedTextLabel.text = ""
        signalStatus.detailedTextLabel.text = "Excellent"
        
        lightStatus.stepper.value = tracker.store.state.lightBattery
        trackerStatus.stepper.value = tracker.store.state.trackerBattery
    }
    
    private func update() {
        deviceDetailedStatus.text = ""
        
        lightStatus.rightLabel.textColor = .black
        sirenStatus.rightLabel.textColor = .black
        trackerStatus.rightLabel.textColor = .black
        
        var text = (tracker.store.state.lightState == .on) ? "ON" : "OFF"
        lightStatus.rightLabel.text = text
        lightStatus.detailedTextLabel.text = "\(tracker.store.state.lightBattery)% remaining"
        
        text = (tracker.store.state.armedState == .armed) ? "ON" : "OFF"
        trackerStatus.rightLabel.text = text
        trackerStatus.detailedTextLabel.text = "\(tracker.store.state.trackerBattery)% remaining"
        
        text = (tracker.store.state.sirenState == .on) ? "ON" : "OFF"
        sirenStatus.rightLabel.text = text
    }
}

extension ViewController: BatteryStatusViewDelegate {
    func batteryStatus(batteryStatus: BatteryStatusView, didChange value: Double) {
        if batteryStatus == lightStatus {
            tracker.store.dispatch(.lightBattery(value))
        } else if batteryStatus == trackerStatus {
            tracker.store.dispatch(.trackerBattery(value))
        }
        
        update()
        bikeTrackerPeripheral.updateTrackerState()
    }
}

extension ViewController: BikeTrackerPeripheralDelegate {
    func trackerPeripheralDidChange(_ tracker: BikeTrackerPeripheral) {
        update()
    }
    
    func trackerPeripheral(_ tracker: BikeTrackerPeripheral, eventDidOccur: String) {
        deviceDetailedStatus.text = eventDidOccur
    }
}
