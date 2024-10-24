//
//  RotatePoint.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 10/24/24.
//

import Foundation
import CoreBluetooth
import simd

func rotatePoint(from characteristic: CBCharacteristic) -> simd_double3? {
    // Convert the value to an array of bytes
    guard let value = characteristic.value else {
        print("Characteristic value is nil")
        return nil
    }
    
    let bytes = [UInt8](value)
    print("Bytes: \(bytes)")
    
    // Validate 32 bytes
    guard bytes.count >= 32 else {
        print("Not enough bytes")
        return nil
    }
    
    // Convert bytes to an array of doubles
    var doubles: [Double] = []
    for i in stride(from: 0, to: 32, by: 8) {
        let byteRange = bytes[i..<i+8]
        let doubleValue = byteRange.withUnsafeBytes { $0.load(as: Double.self) }
        doubles.append(doubleValue)
    }
    print("Doubles: \(doubles)")
    
    // Validate four doubles for the quaternion
    guard doubles.count >= 4 else {
        print("Not enough doubles for quaternion")
        return nil
    }
    
    // Create the quaternion: w, x, y, z
    let quaternion = simd_quatd(ix: doubles[1], iy: doubles[2], iz: doubles[3], r: doubles[0])
    
    let point = simd_double3(1.0, 0.0, 0.0) // Example point
    
    // Rotate the point using the quaternion
    let rotatedPoint = quaternion.act(point)

    return rotatedPoint
}
