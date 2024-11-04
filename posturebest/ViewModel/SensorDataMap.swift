//
//  SensorDataMap.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 11/2/24.
//

import Foundation
import CoreBluetooth
import simd

func SensorDataMap(from characteristic: CBCharacteristic) -> [simd_quatd]? {
    let numSensors = 5;
    let totalBytes = 32 * numSensors
    let totalDoubles = 4 * numSensors
    
    print(totalBytes);

    // Convert the value to an array of bytes
    guard let value = characteristic.value else {
        print("Characteristic value is nil")
        return nil
    }
    
    let bytes = [UInt8](value)
    print("Bytes: \(bytes)")
    
    // Validate 32 bytes per sensor
    guard bytes.count >= totalBytes else {
        print("Not enough bytes")
        return nil
    }
    
    // Convert bytes to an array of doubles
    var doubles: [Double] = []
    for i in stride(from: 0, to: totalBytes, by: 8) {
        let byteRange = bytes[i..<i+8]
        let doubleValue = byteRange.withUnsafeBytes { $0.load(as: Double.self) }
        doubles.append(doubleValue)
    }
    print("Doubles: \(doubles)")
    
    // Validate 4 doubles per sensor for the quaternions
    guard doubles.count >= totalDoubles else {
        print("Not enough doubles for quaternion")
        return nil
    }
    
    // Create the quaternion: w, x, y, z
    let quaternion1 = simd_quatd(ix: doubles[1], iy: doubles[2], iz: doubles[3], r: doubles[0])
    var relativeQuaternions: [simd_quatd] = []
    
    let inverseQuaternion1 = quaternion1.inverse
    
    // Calculate relative quaternions
    for sensorIndex in 1..<numSensors {
        let baseIndex = sensorIndex * 4
        let quaternion = simd_quatd(ix: doubles[baseIndex + 1], iy: doubles[baseIndex + 2], iz: doubles[baseIndex + 3], r: doubles[baseIndex])
        let relativeQuaternion = inverseQuaternion1 * quaternion
        relativeQuaternions.append(relativeQuaternion)
    }
        
        return relativeQuaternions
}

