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
    
    func takeReading(bones: [String: simd_quatf]) {
        // Calculate posture score and graph data
        let result = calculatePostureScore(bones: bones)
        
        // Get the current timestamp
        let timestamp = Date()
        
        // Store the score and graphData with the timestamp in the dictionary
        readings[timestamp] = (score: result.score, graphData: result.graphData)
        
        // Store readings in UserDefaults
        saveReadingsToUserDefaults()
        
        // Optionally, print the reading for debugging
        print("Reading at \(timestamp): Score = \(result.score), Graph Data = \(result.graphData)")
    }
    
    func saveReadingsToUserDefaults() {
        let readingsArray = readings.map { (timestamp, data) -> [String: Any] in
            return [
                "timestamp": timestamp.timeIntervalSince1970,
                "score": data.score,
                "graphData": data.graphData
            ]
        }
        
        // Store the array in UserDefaults
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

    // Define the ideal posture angles (in radians or degrees, depending on calculation)
    let idealSpinalStraightnessAngle: Float = 0.0 // Ideal spinal straightness angle (no curvature)
    let idealHunchAngle: Float = 0.0 // Ideal hunch angle (no rounding)
    let idealShoulderBalanceAngle: Float = 0.0 // Ideal shoulder angle (shoulders aligned)

    // Function to convert a quaternion to Euler angles (pitch, roll, yaw)
    func quaternionToEulerAngles(_ quat: simd_quatf) -> simd_float3 {
        let m = simd_matrix4x4(quat)  // Convert quaternion to 4x4 matrix
        let pitch = atan2(m[2][1], m[2][2])
        let roll  = atan2(m[2][0], sqrt(m[2][1] * m[2][1] + m[2][2] * m[2][2]))
        let yaw   = atan2(m[1][0], m[0][0])
        return simd_float3(pitch, roll, yaw)
    }

    // Function to calculate the angle between two vectors
    func angleBetweenVectors(_ v1: simd_float3, _ v2: simd_float3) -> Float {
        let dotProduct = simd_dot(v1, v2)
        let magnitudeV1 = simd_length(v1)
        let magnitudeV2 = simd_length(v2)
        let cosineTheta = dotProduct / (magnitudeV1 * magnitudeV2)
        return acos(cosineTheta) // In radians
    }
    
    // Function to calculate spinal straightness based on Y-axis angle between spine segments
    func calculateSpinalStraightness(bones: [String: simd_quatf]) -> Float {
        // Extract quaternions for the relevant bones (LowerBack and MidBack or other segments)
        guard let spineBaseQuat = bones["LowerBack"], let spineUpperQuat = bones["MidBack"] else {
            return -1 // Return -1 if the required quaternions are not available
        }
        
        // Convert quaternions to Euler angles
        let spineBaseEuler = quaternionToEulerAngles(spineBaseQuat)
        let spineUpperEuler = quaternionToEulerAngles(spineUpperQuat)
        
        // Extract the Y-axis angles from the Euler angles
        let spineBaseYAngle = spineBaseEuler.y // Y-axis angle (pitch)
        let spineUpperYAngle = spineUpperEuler.y // Y-axis angle (pitch)
        
        // Calculate the absolute difference in the Y-axis angles (spinal straightness angle)
        let spinalStraightnessAngle = abs(spineBaseYAngle - spineUpperYAngle)
        
        return spinalStraightnessAngle // Spinal straightness angle in radians
    }

    // Function to calculate the hunch angle considering X-axis angles from all three back sensors
    func calculateHunchAngle(bones: [String: simd_quatf]) -> Float {
        // Extract quaternions for the relevant bones (LowerBack, MidBack, UpperBack)
        guard let spineBaseQuat = bones["LowerBack"],
              let spineMidQuat = bones["MidBack"],
              let spineUpperQuat = bones["UpperBack"] else {
            return -1 // Return -1 if the required quaternions are not available
        }
        
        // Convert quaternions to Euler angles
        let spineBaseEuler = quaternionToEulerAngles(spineBaseQuat)
        let spineMidEuler = quaternionToEulerAngles(spineMidQuat)
        let spineUpperEuler = quaternionToEulerAngles(spineUpperQuat)
        
        // Extract the X-axis angles from the Euler angles (roll)
        let spineBaseXAngle = spineBaseEuler.x // X-axis angle (roll)
        let spineMidXAngle = spineMidEuler.x // X-axis angle (roll)
        let spineUpperXAngle = spineUpperEuler.x // X-axis angle (roll)
        
        // Calculate the average of the X-axis angles to compute the overall hunch angle
        let averageXAngle = (spineBaseXAngle + spineMidXAngle + spineUpperXAngle) / 3.0
        
        return averageXAngle // Hunch angle in radians
    }

    // Function to calculate the shoulder balance (as it was before, but can be adapted as needed)
    func calculateShoulderBalance(bones: [String: simd_quatf]) -> Float {
        // Extract quaternions for the relevant bones (LeftShoulder and RightShoulder)
        guard let shoulderLeftQuat = bones["LeftShoulder"], let shoulderRightQuat = bones["RightShoulder"], let spineUpperQuat = bones["UpperSpine"] else {
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

    // Normalize the deviation as before (no change needed here)
    func normalizeDeviation(_ activeAngle: Float, idealAngle: Float, maxDeviation: Float) -> Float {
        // Calculate the absolute difference between the active angle and ideal angle
        let deviation = abs(activeAngle - idealAngle)
        // Normalize to a value between 0 and 1 based on max possible deviation
        return min(deviation / maxDeviation, 1.0)
    }

    // Calculate posture score (updated to use new spinal and hunch calculations)
    func calculatePostureScore(bones: [String: simd_quatf]) -> (score: Float, graphData: [Float]) {
        // Calculate angles for each posture section
        let spinalStraightnessAngle = calculateSpinalStraightness(bones: bones)
        let hunchAngle = calculateHunchAngle(bones: bones)
        let shoulderBalanceAngle = calculateShoulderBalance(bones: bones)
        
        // Normalize deviations from the ideal posture for each section
        let normalizedSpinalStraightness = normalizeDeviation(spinalStraightnessAngle, idealAngle: idealSpinalStraightnessAngle, maxDeviation: 25.0)
        let normalizedHunch = normalizeDeviation(hunchAngle, idealAngle: idealHunchAngle, maxDeviation: 25.0)
        let normalizedShoulderBalance = normalizeDeviation(shoulderBalanceAngle, idealAngle: idealShoulderBalanceAngle, maxDeviation: 25.0)
        
        // Weights for each category
        let spinalStraightnessWeight: Float = 0.2
        let hunchWeight: Float = 0.4
        let shoulderBalanceWeight: Float = 0.4
        
        // Calculate final score (weighted sum of the normalized deviations)
        let finalScore = (normalizedSpinalStraightness * spinalStraightnessWeight) +
                         (normalizedHunch * hunchWeight) +
                         (normalizedShoulderBalance * shoulderBalanceWeight)
        
        // Prepare graph data (normalized deviations for each category)
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
