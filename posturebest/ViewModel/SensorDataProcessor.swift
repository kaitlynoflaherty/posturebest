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
    var readings: [Date: (score: Float, graphData: [Float])] = [:]

    let boneNames = ["LowerBack", "MidBack", "UpperBack", "Shoulder-Right"]
    
    func quatToEuler(_ quat: simd_quatf) -> SIMD3<Float> {
        let n = SCNNode()
        n.simdOrientation = quat
        return n.simdEulerAngles
    }
        
    func normalizeSensors(boneName: String) {
        let qReferenceOrientation = modelHelper.getReferenceOrientation(boneName: boneName)
        
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
        let numSensors = 4
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
                
                if index > 0 && index < 3{
                    let intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary[boneNames[index-1]]!.conjugate
                    
                    let updatedRotations = simd_quatf(ix: intermediate.imag.z,
                                                   iy: -intermediate.imag.y,
                                                   iz: intermediate.imag.x,
                                                   r: intermediate.real)
                    actualRotations[boneNames[index]] = updatedRotations
                } else if index > 2 {
                    let intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary[boneNames[index-1]]!.conjugate
                    
                    let updatedRotations = simd_quatf(ix: intermediate.imag.y,
                                                   iy: intermediate.imag.x,
                                                   iz: intermediate.imag.z,
                                                   r: intermediate.real)
                    
                    let shoulderNormalizer = simd_quatf(real: -0.36710772, imag: SIMD3<Float>(0.5030935, -0.4599741, -0.6328925))
                    actualRotations[boneNames[index]] = shoulderNormalizer * updatedRotations
                }
            }
        }
        sensorsCalibrated = true
    }

    func traverseNodes() {
        var actions: [SCNAction] = []
        takeReading(bones: orientationDictionary)
        
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
        
        if let rightShoulderNode = modelHelper.getShoulderRightNode() {
            let angle = quatToEuler(actualRotations[rightShoulderNode.name!]!)
            let animation = SCNAction.rotateTo(x: CGFloat(angle.x), y: CGFloat(angle.y), z: CGFloat(angle.z), duration: 0.5, usesShortestUnitArc: true)
            let backBend = SCNAction.customAction(duration: 0.5) {
                (node, elapsedTime) in rightShoulderNode.runAction(animation)}
            actions.append(backBend)
        } else {
            print("No Shoulder.Right node found.")
        }
        
        let rootNode = modelHelper.getRootNode()
        rootNode?.runAction(SCNAction.sequence(actions))
    }
    
    func takeReading(bones: [String: simd_quatf]) {
        let result = calculatePostureScore(bones: bones)

        let timestamp = Date()
        readings[timestamp] = (score: result!.score, graphData: result!.graphData)
        
        // Store readings in UserDefaults
//        saveReadingsToUserDefaults()
        
        print("Reading at \(timestamp): Score = \(result!.score), Graph Data = \(result!.graphData)")
    }
    
    func saveReadingsToUserDefaults() {
        let readingsArray = readings.map { (timestamp, data) -> [String: Any] in
            return [
                "timestamp": timestamp.timeIntervalSince1970,
                "score": data.score,
                "graphData": data.graphData
            ]
        }
        
        UserDefaults.standard.set(readingsArray, forKey: "postureReadings")
    }
    
    func loadReadingsFromUserDefaults() {
        if let savedReadings = UserDefaults.standard.array(forKey: "postureReadings") as? [[String: Any]] {
            for reading in savedReadings {
                if let timestampInterval = reading["timestamp"] as? TimeInterval,
                   let score = reading["score"] as? Float,
                   let graphData = reading["graphData"] as? [Float] {
                    
                    let timestamp = Date(timeIntervalSince1970: timestampInterval)
                    readings[timestamp] = (score, graphData)
                }
            }
        }
    }

    let idealSpinalStraightnessAngle: Float = 0.0
    let idealHunchAngle: Float = 0.0
    let idealShoulderBalanceAngle: Float = 0.0

    func quaternionToEulerAngles(_ quat: simd_quatf) -> simd_float3 {
        let m = simd_matrix4x4(quat)
        let pitch = atan2(m[2][1], m[2][2])
        let roll  = atan2(m[2][0], sqrt(m[2][1] * m[2][1] + m[2][2] * m[2][2]))
        let yaw   = atan2(m[1][0], m[0][0])
        return simd_float3(pitch, roll, yaw)
    }

    func angleBetweenVectors(_ v1: simd_float3, _ v2: simd_float3) -> Float {
        let dotProduct = simd_dot(v1, v2)
        let magnitudeV1 = simd_length(v1)
        let magnitudeV2 = simd_length(v2)
        let cosineTheta = dotProduct / (magnitudeV1 * magnitudeV2)
        return acos(cosineTheta) // In radians
    }
    
    func calculateSpinalStraightness(bones: [String: simd_quatf]) -> Float {
        guard
            let spineBaseQuat = bones["LowerBack"],
                let spineMidQuat = bones["MidBack"],
                let spineUpperQuat = bones["UpperBack"]  else {
            return -1
        }
        
        let relativeLower = spineMidQuat * spineBaseQuat.conjugate
        let relativeUpper = spineUpperQuat * spineMidQuat.conjugate
        
        let relativeLowerEuler = quaternionToEulerAngles(relativeLower)
        let relativeUpperEuler = quaternionToEulerAngles(relativeUpper)
        
        let spineBaseAngle = relativeLowerEuler.z
        let spineUpperAngle = relativeUpperEuler.z
        
        let spinalStraightnessAngle = abs(spineBaseAngle) + abs(spineUpperAngle)
        print("spinalStraightnessAngle: \(spinalStraightnessAngle)")
        return spinalStraightnessAngle
    }

    func calculateHunchAngle(bones: [String: simd_quatf]) -> Float {
        print("bones:\(bones)")
        guard let spineBaseQuat = bones["LowerBack"],
              let spineMidQuat = bones["MidBack"],
              let spineUpperQuat = bones["UpperBack"] else {
            return -1
        }
        
        let relativeLower = spineMidQuat * spineBaseQuat.conjugate
        let relativeUpper = spineUpperQuat * spineMidQuat.conjugate
        
        let relativeLowerEuler = quaternionToEulerAngles(relativeLower)
        let relativeUpperEuler = quaternionToEulerAngles(relativeUpper)
        
        let spineBaseAngle = relativeLowerEuler.y
        let spineUpperAngle = relativeUpperEuler.y
        
        let sumAngle = spineBaseAngle + spineUpperAngle
        return sumAngle
    }

    func calculateShoulderBalance(bones: [String: simd_quatf]) -> Float {
        guard let shoulderLeftQuat = bones["Shoulder-Left"],
                let shoulderRightQuat = bones["Shoulder-Right"],
                let spineUpperQuat = bones["UpperBack"] else {
            return -1
        }
        
        // Convert quaternions to Euler angles
        let shoulderLeftEuler = quaternionToEulerAngles(shoulderLeftQuat)
        let shoulderRightEuler = quaternionToEulerAngles(shoulderRightQuat)
        let spineUpperEuler = quaternionToEulerAngles(spineUpperQuat)
        
        let shoulderLeftVec = simd_float3(shoulderLeftEuler.x, shoulderLeftEuler.y, shoulderLeftEuler.z)
        let shoulderRightVec = simd_float3(shoulderRightEuler.x, shoulderRightEuler.y, shoulderRightEuler.z)
        let spineUpperVec = simd_float3(spineUpperEuler.x, spineUpperEuler.y, spineUpperEuler.z)
        
        return angleBetweenVectors(shoulderLeftVec, shoulderRightVec)
    }

    func normalizeDeviation(_ activeAngle: Float, idealAngle: Float, maxDeviation: Float) -> Float {
        let deviation = abs(activeAngle - idealAngle)
        return min(deviation / maxDeviation, 1.0)
    }

    func calculatePostureScore(bones: [String: simd_quatf]) -> (score: Float, graphData: [Float])? {
        let spinalStraightnessAngle = calculateSpinalStraightness(bones: bones)
        let hunchAngle = calculateHunchAngle(bones: bones)
        print("hunchhhh: \(hunchAngle)")
        let shoulderBalanceAngle = calculateShoulderBalance(bones: bones)
        
        if spinalStraightnessAngle == -1 || hunchAngle == -1 || shoulderBalanceAngle == -1 {
            print("calculatePostureScore Error: angle not found")
            return nil
        }

        let normalizedSpinalStraightness = normalizeDeviation(spinalStraightnessAngle, idealAngle: idealSpinalStraightnessAngle, maxDeviation: ((25.0 * .pi) / 180))
        let normalizedHunch = normalizeDeviation(hunchAngle, idealAngle: idealHunchAngle, maxDeviation: ((25.0 * .pi) / 180))
        let normalizedShoulderBalance = normalizeDeviation(shoulderBalanceAngle, idealAngle: idealShoulderBalanceAngle, maxDeviation: ((25.0 * .pi) / 180))
        
        let spinalStraightnessWeight: Float = 0.2
        let hunchWeight: Float = 0.4
        let shoulderBalanceWeight: Float = 0.4
        
        let finalScore = (normalizedSpinalStraightness * spinalStraightnessWeight) +
                         (normalizedHunch * hunchWeight) +
                         (normalizedShoulderBalance * shoulderBalanceWeight)

        let graphData: [Float] = [normalizedSpinalStraightness, normalizedHunch, normalizedShoulderBalance]
        
        return (finalScore, graphData)
    }
    

//    // Function to calculate spinal straightness
//    func calculateSpinalStraightness(bones: [String: simd_quatf]) -> Float {
//        // Extract quaternions for the relevant bones
//        guard let spineBaseQuat = bones["LowerBack"], let spineUpperQuat = bones["MidBack"] else {
//            return -1 // maybe take this out....
//        }
//        
//        // Convert quaternions to Euler angles
//        let spineBaseEuler = quaternionToEulerAngles(spineBaseQuat)
//        let spineUpperEuler = quaternionToEulerAngles(spineUpperQuat)
//        
//        let spineBaseVec = simd_float3(spineBaseEuler.x, spineBaseEuler.y, spineBaseEuler.z)
//        let spineUpperVec = simd_float3(spineUpperEuler.x, spineUpperEuler.y, spineUpperEuler.z)
//        
//        return angleBetweenVectors(spineBaseVec, spineUpperVec) // Spinal straightness angle
//    }
//
//    // Function to calculate the hunch angle
//    func calculateHunchAngle(bones: [String: simd_quatf]) -> Float {
//        // Extract quaternions for the relevant bones
//        guard let shoulderLeftQuat = bones["LeftShoulder"], let shoulderRightQuat = bones["RightShoulder"] else {
//            return -1
//        }
//        
//        // Convert quaternions to Euler angles
//        let shoulderLeftEuler = quaternionToEulerAngles(shoulderLeftQuat)
//        let shoulderRightEuler = quaternionToEulerAngles(shoulderRightQuat)
//        
//        let shoulderLeftVec = simd_float3(shoulderLeftEuler.x, shoulderLeftEuler.y, shoulderLeftEuler.z)
//        let shoulderRightVec = simd_float3(shoulderRightEuler.x, shoulderRightEuler.y, shoulderRightEuler.z)
//        
//        return angleBetweenVectors(shoulderLeftVec, shoulderRightVec) // Hunch angle
//    }
//
//    // Function to calculate shoulder balance
//    func calculateShoulderBalance(bones: [String: simd_quatf]) -> Float {
//        // Extract quaternions for the relevant bones
//        guard let shoulderLeftQuat = bones["LeftShoulder"], let shoulderRightQuat = bones["RightShoulder"], let spineUpperQuat = bones["UpperSpine"] else {
//            return -1
//        }
//        
//        // Convert quaternions to Euler angles
//        let shoulderLeftEuler = quaternionToEulerAngles(shoulderLeftQuat)
//        let shoulderRightEuler = quaternionToEulerAngles(shoulderRightQuat)
//        let spineUpperEuler = quaternionToEulerAngles(spineUpperQuat)
//        
//        let shoulderLeftVec = simd_float3(shoulderLeftEuler.x, shoulderLeftEuler.y, shoulderLeftEuler.z)
//        let shoulderRightVec = simd_float3(shoulderRightEuler.x, shoulderRightEuler.y, shoulderRightEuler.z)
//        let spineUpperVec = simd_float3(spineUpperEuler.x, spineUpperEuler.y, spineUpperEuler.z)
//        
//        return angleBetweenVectors(shoulderLeftVec, shoulderRightVec)
//    }
//
//    // Function to normalize the angle deviation from ideal
//    func normalizeDeviation(_ activeAngle: Float, idealAngle: Float, maxDeviation: Float) -> Float {
//        // Calculate the absolute difference between the active angle and ideal angle
//        let deviation = abs(activeAngle - idealAngle)
//        // Normalize to a value between 0 and 1 based on max possible deviation
//        return min(deviation / maxDeviation, 1.0)
//    }
//
//    // Function to calculate the posture score based on active posture compared to ideal posture
//    func calculatePostureScore(bones: [String: simd_quatf]) -> (score: Float, graphData: [Float]) {
//        // Calculate angles for each posture section
//        let spinalStraightnessAngle = calculateSpinalStraightness(bones: bones)
//        let hunchAngle = calculateHunchAngle(bones: bones)
//        let shoulderBalanceAngle = calculateShoulderBalance(bones: bones)
//        
//        // Normalize deviations from the ideal posture for each section
//        let normalizedSpinalStraightness = normalizeDeviation(spinalStraightnessAngle, idealAngle: idealSpinalStraightnessAngle, maxDeviation: 25.0)
//        let normalizedHunch = normalizeDeviation(hunchAngle, idealAngle: idealHunchAngle, maxDeviation: 25.0)
//        let normalizedShoulderBalance = normalizeDeviation(shoulderBalanceAngle, idealAngle: idealShoulderBalanceAngle, maxDeviation: 25.0)
//        
//        // Weights for each category
//        let spinalStraightnessWeight: Float = 0.2
//        let hunchWeight: Float = 0.4
//        let shoulderBalanceWeight: Float = 0.4
//        
//        // Calculate final score (weighted sum of the normalized deviations)
//        let finalScore = (normalizedSpinalStraightness * spinalStraightnessWeight) +
//                         (normalizedHunch * hunchWeight) +
//                         (normalizedShoulderBalance * shoulderBalanceWeight)
//        
//        // Prepare graph data (normalized deviations for each category)
//        let graphData: [Float] = [normalizedSpinalStraightness, normalizedHunch, normalizedShoulderBalance]
//        
//        return (finalScore, graphData)
//    }

    // Example usage with bone data (mock data)
//    let mockBones: [String: simd_quatf] = [
//        "spine_base": simd_quatf(angle: 0.1, axis: simd_float3(1, 0, 0)), // Spine base quaternion
//        "spine_upper": simd_quatf(angle: 0.2, axis: simd_float3(1, 0, 0)), // Spine upper quaternion
//        "shoulder_left": simd_quatf(angle: 0.3, axis: simd_float3(1, 0, 0)), // Left shoulder quaternion
//        "shoulder_right": simd_quatf(angle: 0.4, axis: simd_float3(1, 0, 0)) // Right shoulder quaternion
//    ]

//    let result = calculatePostureScore(bones: mockBones)
//    print("Posture Score: \(result.score)") // Weighted score
//    print("Graph Data: \(result.graphData)") // Angles for graph


}
