//
//  RotatePoint.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 10/24/24.
//

import Foundation
import CoreBluetooth
import simd

func rotatePoint(from characteristic: CBCharacteristic) -> Double? {
    // Convert the value to an array of bytes
    guard let value = characteristic.value else {
        print("Characteristic value is nil")
        return nil
    }
    
    let bytes = [UInt8](value)
    print("Bytes: \(bytes)")
    
    // Validate 32 bytes
    guard bytes.count >= 64 else {
        print("Not enough bytes")
        return nil
    }
    
    // Convert bytes to an array of doubles
    var doubles: [Double] = []
    for i in stride(from: 0, to: 64, by: 8) {
        let byteRange = bytes[i..<i+8]
        let doubleValue = byteRange.withUnsafeBytes { $0.load(as: Double.self) }
        doubles.append(doubleValue)
    }
    print("Doubles: \(doubles)")
    
    // Validate 8 doubles for the 2 quaternion
    guard doubles.count >= 8 else {
        print("Not enough doubles for quaternion")
        return nil
    }
    
    // Create the quaternion: w, x, y, z
    let quaternion1 = simd_quatd(ix: doubles[1], iy: doubles[2], iz: doubles[3], r: doubles[0])
    let quaternion2 = simd_quatd(ix: doubles[5], iy: doubles[6], iz: doubles[7], r: doubles[4])
    
    let q1conjugate = quaternion1.conjugate
    let product = q1conjugate * quaternion2
    
    return product.angle
}
