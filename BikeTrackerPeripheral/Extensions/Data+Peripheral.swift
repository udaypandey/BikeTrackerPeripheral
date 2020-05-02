//
//  Data+Peripheral.swift
//  BikeTrackerPeripheral
//
//  Created by Uday Pandey on 05/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import Foundation

extension Data {
    var dataAfterAppendingHeader: Data {
        let byte0:UInt8 = 0xaa
        let byte1:UInt8 = 0x55
        let byte2:UInt8 = 0xaa
        let byte3:UInt8 = msb
        let byte4:UInt8 = lsb
        
        var headerData = Data([byte0, byte1, byte2, byte3, byte4])
        headerData.append(self)
        return headerData
    }
    
    var dataAfterStrippingHeader: Data {
        return subdata(in: 5..<self.count)
    }

    private var msb: UInt8 {
        // Most significant byte Assuming count of message is less than 2^16
        let length = UInt16(self.count)
        let msb = UInt8((length >> 8) & 0xff)
        return msb
    }
    
    private var lsb: UInt8 {
        // Least significant byte
        let length = UInt16(self.count)
        let lsb = UInt8(length & 0xff)
        return lsb
    }
}

extension Data {
    func model<T: Decodable>(for type: T.Type) -> T? {
        // Intentionally written in verbose way to catch and print
        // any parse issues and print them while writing test
        // case.
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: self)
        } catch {
            DebugLogger.info("Model Parse error: \(error)")
        }

        return nil
    }

    static func modelData<T: Encodable>(for value: T) -> Data? {
        // Intentionally written in verbose way to catch and print
        // any parse issues and print them while writing test
        // case.
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(value)
        } catch {
            DebugLogger.info("Model Parse error: \(error)")
        }

        return nil
    }

}


