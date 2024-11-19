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

// import Torso3DView for skeletonNode (has the hierarchy for child nodes)

class SensorDataProcessor {
    var orientationDictionary: [String: simd_quatf] = [:]
    var orientationAdjustments: [String: simd_quatf] = [:]
    var actualRotations: [String : simd_quatf] = [:]
    var qReferenceOrientation: simd_quatf?
    var torso3DUtil = Torso3DUtil()


//    let boneNames = ["midBack", "upperBack", "rightShoulder", "leftShoulder"]
    let boneNames = ["LowerBack", "MidBack", "UpperBack"]
//    let q_90 = simd_quatf(ix: -0.5, iy: 0.5, iz: 0.5, r: 0.5)
    
    func normalizeSensors() {
        qReferenceOrientation = torso3DUtil.getReferenceOrientation()
        
        for (index, boneName) in boneNames.enumerated() {
            orientationAdjustments[boneName] = qReferenceOrientation! * orientationDictionary[boneName]!.conjugate
        }
        
    }

    func MapSensorDataToBones(from characteristic: CBCharacteristic) -> [String: simd_quatf]? {
        
        let numSensors = 3
        let totalBytes = 32 * numSensors
        let totalDoubles = 4 * numSensors
        
//        let qFixed = simd_quatf(ix: 0.5, iy: 0.5, iz: 0.5, r: 0.5)

//        print("Total bytes: \(totalBytes)")

        // Convert the value to an array of bytes
        guard let value = characteristic.value else {
            print("Characteristic value is nil")
            return nil
        }

        let bytes = [UInt8](value)
//        print("Bytes: \(bytes)")

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
//        print("Doubles: \(doubles)")

        // Validate 4 doubles per sensor for the quaternions
        guard doubles.count >= totalDoubles else {
            print("Not enough doubles for quaternion")
            return nil
        }

        // Create the quaternion: w, x, y, z
//        let quaternion0 = simd_quatf(ix: Float(doubles[1]), iy: Float(doubles[2]), iz: Float(doubles[3]), r: Float(doubles[0]))
//                print("Quaternion0: \(quaternion0)")
//
//        // Update the quaternion for lowerBack (root node)
//        orientationDictionary["LowerBack"] = quaternion0

//        // Update quaternions for each bone in the dictionary
//        for sensorIndex in 1..<numSensors {
//            let baseIndex = sensorIndex * 4
//            let quaternion = simd_quatf(ix: Float(doubles[baseIndex + 1]), iy: Float(doubles[baseIndex + 2]), iz: Float(doubles[baseIndex + 3]), r: Float(doubles[baseIndex])) * quaternion0.conjugate
//            
//            // Directly map quat to the bone name
//            if sensorIndex - 1 < boneNames.count {
//                orientationDictionary[boneNames[sensorIndex - 1]] = quaternion * quaternion0.conjugate
//            }
//        }
//        
//        for boneName in boneNames {
//            orientationDictionary[boneName] = orientationDictionary[boneName]! * orientationAdjustments[boneName]!
//            
//        }
//        
//        let qRot = qFixed * orientationDictionary["LowerBack"]!.conjugate
//        
//        for boneName in boneNames {
//            orientationDictionary[boneName] = qRot * orientationDictionary[boneName]!
//        }
        
        for (index, boneName) in boneNames.enumerated() {
            if index < numSensors {
                let baseIndex = index * 4
                let quaternion = simd_quatf(ix: Float(doubles[baseIndex + 1]),
                                             iy: Float(doubles[baseIndex + 2]),
                                             iz: Float(doubles[baseIndex + 3]),
                                             r: Float(doubles[baseIndex]))
                
                if qReferenceOrientation == nil {
                    orientationDictionary[boneName] = /*q_90 **/ quaternion
                } else {
                    orientationDictionary[boneName] = orientationAdjustments[boneName]! * /*(q_90 **/ quaternion
                }
//                print("Quaternion for \(boneName): \(quaternion)")
                
                
                if index > 0 {
                    var intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary[boneNames[index-1]]!.conjugate
                    
                    var updatedRotations = simd_quatf(ix: Float(-intermediate.imag.z),
                                                   iy: intermediate.imag.y,
                                                   iz: Float(-intermediate.imag.x),
                                                   r: intermediate.real)
                    actualRotations[boneNames[index]] = updatedRotations
                }
            }
        }
        print("actualRotations dictionary: \(actualRotations)")
        if qReferenceOrientation == nil {
            normalizeSensors()
        }
        
//         Apply fixed rotation to all bones
//        if let lowerBackQuaternion = orientationDictionary["LowerBack"] {
//            let qRot = qFixed * lowerBackQuaternion.conjugate
//
//            for boneName in boneNames {
//                if var boneQuaternion = orientationDictionary[boneName] {
//                    boneQuaternion = qRot * boneQuaternion
//                    orientationDictionary[boneName] = boneQuaternion
//                }
//            }
//        }

//        print("Updated Orientation Dictionary: \(orientationDictionary)")
        return orientationDictionary
    }

    func traverseNodes(node: SCNNode) {
        node.simdOrientation = actualRotations[node.name!]!
        
        
        /*var cursor = node.simdWorldOrientation
        

        let predicate: (SCNNode, UnsafeMutablePointer<ObjCBool>) -> Bool = { node, stop in
            if let _ = self.orientationDictionary[node.name!] {
                return true
            }
            return false
        }

        let nodesToTraverse = node.childNodes(passingTest: predicate)
        print("nodesToTraverse \(nodesToTraverse)")

        node.enumerateHierarchy { (boneNode, stop) in
            print("boneNode \(boneNode)")
//            boneNode.removeAllActions()
//            boneNode.physicsBody = nil


            // Check if the bone node is one of the nodes to traverse
            if nodesToTraverse.contains(boneNode) {
                print("Updating bone orientation")

                if let orientation = orientationDictionary[boneNode.name!] {
                    
                    boneNode.simdWorldOrientation = orientation

//                    // Apply the orientation to the node
//                    print("Before updating: \(boneNode.simdOrientation)")
//                    boneNode.simdOrientation = orientation * cursor.conjugate
////                    boneNode.position = SCNVector3(x: 1, y: 1, z: 1)
////
////                    let testQuaternion = simd_quatf(angle: Float.pi / 2, axis: [0, 1, 0])
////                    boneNode.simdOrientation = testQuaternion
//                    print("After updating: \(boneNode.simdOrientation)")
//                    cursor = orientation
                }
            } else {
                // Keep traversing the hierarchy, applying the previous cursor
                print("Not updating, continuing traversal")
                cursor = boneNode.simdOrientation * cursor.conjugate
            }
        }*/
    }


}
