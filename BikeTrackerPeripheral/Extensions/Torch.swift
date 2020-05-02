//
//  Torch.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 05/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation
import AVFoundation

func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: .video),
        device.hasTorch else { return }

    do {
        try device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    } catch {
        DebugLogger.info("Torch could not be used")
    }
}
