//
//  TraverseModel.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 11/6/24.
//

import Foundation
import simd
import CoreBluetooth
import SceneKit

// import Torso3DView for skeletonNode (has the hierarchy for child nodes)

class SensorDataProcessor {
    var orientationDictionary: [String: simd_quatf] = [:]
//    let boneNames = ["midBack", "upperBack", "rightShoulder", "leftShoulder"]
    let boneNames = ["midBack", "upperBack"]
    
    func MapSensorDataToBones(from characteristic: CBCharacteristic) -> [String: simd_quatf]? {
        let numSensors = 5
        let totalBytes = 32 * numSensors
        let totalDoubles = 4 * numSensors
        
        print("Total bytes: \(totalBytes)")
        
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
            let byteRange = bytes[i..<i + 8]
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
        let quaternion0 = simd_quatf(ix: Float(doubles[1]), iy: Float(doubles[2]), iz: Float(doubles[3]), r: Float(doubles[0]))
                print("Quaternion0: \(quaternion0)")
        
        // Update the quaternion for lowerBack (root node)
        orientationDictionary["lowerBack"] = quaternion0
                
        // Update quaternions for each bone in the dictionary
        for sensorIndex in 1..<numSensors {
            let baseIndex = sensorIndex * 4
            let quaternion = simd_quatf(ix: Float(doubles[baseIndex + 1]), iy: Float(doubles[baseIndex + 2]), iz: Float(doubles[baseIndex + 3]), r: Float(doubles[baseIndex]))
            // Directly map quat to the bone name
            if sensorIndex - 1 < boneNames.count {
                orientationDictionary[boneNames[sensorIndex - 1]] = quaternion
            }
        }
        
        print("Updated Orientation Dictionary: \(orientationDictionary)")
        return orientationDictionary
    }
    
    func traverseNodes(node: SCNNode) {
        var cursor =  node.simdWorldOrientation

        let predicate: (SCNNode, UnsafeMutablePointer<ObjCBool>) -> Bool = { node, stop in
            if let _ = self.orientationDictionary[node.name!] {
                return true
            }
            return false
        }
        
        let nodesToTraverse = node.childNodes(passingTest: predicate)
        print("nodesToTraverse \(nodesToTraverse)")
        
        node.enumerateHierarchy { (boneNode, stop) in
                if nodesToTraverse.contains(boneNode) {
                    if let orientation = self.orientationDictionary[node.name!] {
                        boneNode.simdOrientation = orientation * cursor.conjugate
                        cursor = orientation
                    }
                } else {
                    cursor = boneNode.simdOrientation * cursor.conjugate
                }
        }
        
    }

}
