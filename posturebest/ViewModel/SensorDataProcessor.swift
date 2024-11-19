//
//  SensorDataProcessor.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 11/6/24.
//

import Foundation
import simd
import CoreBluetooth
import SceneKit

class SensorDataProcessor {
    var orientationDictionary: [String: simd_quatf] = [:]
    var orientationAdjustments: [String: simd_quatf] = [:]
    var actualRotations: [String : simd_quatf] = [:]
    var qReferenceOrientation: simd_quatf?
    var modelHelper = ModelHelper()

    let boneNames = ["LowerBack", "MidBack", "UpperBack"]
        
    func normalizeSensors() {
        qReferenceOrientation = modelHelper.getReferenceOrientation()
        
        for (_, boneName) in boneNames.enumerated() {
            orientationAdjustments[boneName] = qReferenceOrientation! * orientationDictionary[boneName]!.conjugate
        }
        
    }

    func ParseSensorData(characteristic: CBCharacteristic, numSensors: Int, totalBytes: Int, totalDoubles: Int) -> [Double]? {
        // Convert the value to an array of bytes
        guard let value = characteristic.value else {
            print("Characteristic value is nil")
            return nil
        }

        let bytes = [UInt8](value)

        // Validate 32 bytes per sensor
        guard bytes.count >= totalBytes else {
            print("Not enough bytes")
            return nil
        }

        // Convert bytes to an array of doubles
        var doubles: [Double] = []
        for i in stride(from: 0, to: totalBytes, by: 8) {
            let byteRange = bytes[i..<i + 8]
            let doubleValue = byteRange.withUnsafeBytes { $0.load(as: Double.self) }
            doubles.append(doubleValue)
        }

        // Validate 4 doubles per sensor for the quaternions
        guard doubles.count >= totalDoubles else {
            print("Not enough doubles for quaternion")
            return nil
        }
        return doubles
    }
    
    func MapSensorDataToBones(from characteristic: CBCharacteristic) {
        let numSensors = 3
        let totalBytes = 32 * numSensors
        let totalDoubles = 4 * numSensors
        
        let doubles = ParseSensorData(characteristic: characteristic, numSensors: numSensors, totalBytes: totalBytes, totalDoubles: totalDoubles)
        
        for (index, boneName) in boneNames.enumerated() {
            if index < numSensors {
                let baseIndex = index * 4
                let quaternion = simd_quatf(ix: Float(doubles![baseIndex + 1]),
                                            iy: Float(doubles![baseIndex + 2]),
                                            iz: Float(doubles![baseIndex + 3]),
                                             r: Float(doubles![baseIndex]))
                
                if qReferenceOrientation == nil {
                    orientationDictionary[boneName] = quaternion
                } else {
                    orientationDictionary[boneName] = orientationAdjustments[boneName]! * quaternion
                }
                
                if index > 0 {
                    let intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary[boneNames[index-1]]!.conjugate
                    
                    let updatedRotations = simd_quatf(ix: Float(-intermediate.imag.z),
                                                   iy: intermediate.imag.y,
                                                   iz: Float(-intermediate.imag.x),
                                                   r: intermediate.real)
                    actualRotations[boneNames[index]] = updatedRotations
                }
            }
        }

        if qReferenceOrientation == nil {
            normalizeSensors()
        }
    }

    func traverseNodes(node: SCNNode) {
        node.simdOrientation = actualRotations[node.name!]!
    }


}
