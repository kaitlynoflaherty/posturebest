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
    var modelHelper = ModelHelper()
    var sensorsCalibrated = false

    let boneNames = ["LowerBack", "MidBack", "UpperBack"]
    
    func quatToEuler(_ quat: simd_quatf) -> SIMD3<Float> {
        let n = SCNNode()
        n.simdOrientation = quat
        return n.simdEulerAngles
    }
        
    func normalizeSensors(boneName: String) {
        let qReferenceOrientation = modelHelper.getReferenceOrientation()
        
        orientationAdjustments[boneName] = qReferenceOrientation * orientationDictionary[boneName]!.conjugate
        orientationDictionary[boneName] = qReferenceOrientation
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
                
                if sensorsCalibrated == false {
                    orientationDictionary[boneName] = quaternion
                    normalizeSensors(boneName: boneName)
                } else {
                    orientationDictionary[boneName] = orientationAdjustments[boneName]! * quaternion
                }
                
                if index > 0 {
                    let intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary[boneNames[index-1]]!.conjugate
                    
                    let updatedRotations = simd_quatf(ix: intermediate.imag.z,
                                                   iy: -intermediate.imag.y,
                                                   iz: intermediate.imag.x,
                                                   r: intermediate.real)
                    actualRotations[boneNames[index]] = updatedRotations
                }
            }
        }
        sensorsCalibrated = true
    }

    func traverseNodes() {
        var actions: [SCNAction] = []
        
        if let UpperBackNode = modelHelper.getUpperNode() {
            let angle = quatToEuler(actualRotations[UpperBackNode.name!]!)
            
            let animation = SCNAction.rotateTo(x: CGFloat(angle.x), y: CGFloat(angle.y), z: CGFloat(angle.z), duration: 0.5)
            let backBend = SCNAction.customAction(duration: 0.5) {
                (node, elapsedTime) in UpperBackNode.runAction(animation)}
            actions.append(backBend)
        } else {
            print("No UpperBackNode found.")
        }
        
        if let MidBackNode = modelHelper.getMidNode() {
            let angle = quatToEuler(actualRotations[MidBackNode.name!]!)
            
            let animation = SCNAction.rotateTo(x: CGFloat(angle.x), y: CGFloat(angle.y), z: CGFloat(angle.z), duration: 0.5)
            let backBend = SCNAction.customAction(duration: 0.5) {
                (node, elapsedTime) in MidBackNode.runAction(animation)}
            actions.append(backBend)
        } else {
            print("No MidBackNode found.")
        }
        
        let rootNode = modelHelper.getRootNode()
        rootNode?.runAction(SCNAction.sequence(actions))
    }
}
