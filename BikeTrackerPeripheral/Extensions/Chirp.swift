//
//  Chirp.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 06/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation
import AVFoundation

func chirp() {
    // create a sound ID, in this case its the tweet sound.
    let systemSoundID: SystemSoundID = 1016

    // to play sound
    AudioServicesPlaySystemSound(systemSoundID)
}

class Siren {
    let sirenEffect: AVAudioPlayer?

    init() {
        let path = Bundle.main.path(forResource: "Siren", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)

        sirenEffect = try? AVAudioPlayer(contentsOf: url)
    }
    
    func start() {
        sirenEffect?.play()
    }
    
    func stop() {
        sirenEffect?.stop()
    }
}
