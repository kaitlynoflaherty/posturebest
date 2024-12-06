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

var isConfigured: Bool = false
var score: Float = 0
var isNotifsToggled: Bool = false

class SensorDataProcessor {
    var orientationDictionary: [String: simd_quatf] = [:] // absolute orientations post adjustment
    var orientationAdjustments: [String: simd_quatf] = [:] // orientation of ideal initial connection pose
    var actualRotations: [String : simd_quatf] = [:] // relative orientations between previous sensor and current
   
    var modelHelper = ModelHelper()
    var sensorsCalibrated = false
    var readings: [Date: (score: Float, graphData: [Float])] = [:]

    let boneNames = ["LowerBack", "MidBack", "UpperBack", "Shoulder-Right", "Shoulder-Left"]
    var idealOrientations: [String: simd_quatf] = [:]
    
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
        print(isConfigured)
        let numSensors = 5
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
                    var intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary[boneNames[index-1]]!.conjugate
                    
                    let updatedRotations = simd_quatf(ix: intermediate.imag.z,
                                                   iy: -intermediate.imag.y,
                                                   iz: intermediate.imag.x,
                                                   r: intermediate.real)
                    actualRotations[boneNames[index]] = updatedRotations
                } else if index == 3 {
                    // right shoulder
                    let intermediate = orientationDictionary[boneNames[index]]! * orientationDictionary["UpperBack"]!.conjugate
                    
                    let updatedRotations = simd_quatf(ix: intermediate.imag.x,
                                                      iy: intermediate.imag.y,
                                                      iz: intermediate.imag.z,
                                                      r: intermediate.real)
                    
                    let shoulderNormalizer = simd_quatf(real: -0.12369983, imag: SIMD3<Float>(-0.4146454, -0.68663114, 0.5842135))
                    actualRotations[boneNames[index]] = shoulderNormalizer * updatedRotations
                } else if index == 4 {
                    // left shoulder
                    let orientationDictVar = orientationDictionary[boneNames[index]]!
                    let orientationDictUpper = orientationDictionary["UpperBack"]!
                    
                    let swappedDictVar = simd_quatf(ix: orientationDictVar.imag.y, iy: -orientationDictVar.imag.z, iz: -orientationDictVar.imag.x, r: orientationDictVar.real)
                    let swappedDictUpper = simd_quatf(ix: orientationDictUpper.imag.y, iy: -orientationDictUpper.imag.z, iz: -orientationDictUpper.imag.x, r: orientationDictUpper.real)
                    
                    let swappedIntermediate = swappedDictVar * swappedDictUpper.conjugate
                    
                    let updatedRotations = simd_quatf(ix: swappedIntermediate.imag.x,
                                                      iy: swappedIntermediate.imag.y,
                                                      iz: swappedIntermediate.imag.z,
                                                      r: swappedIntermediate.real)
                    
                    let shoulderNormalizer = simd_quatf(real: -0.7662043, imag: SIMD3<Float>(0.36864018, -0.0913997, -0.5183451))
                    actualRotations[boneNames[index]] = shoulderNormalizer * updatedRotations
                }
            }
        }
        sensorsCalibrated = true
        if isConfigured == true {
            print("HEYYYYY")
            idealOrientations = orientationDictionary
            isConfigured = false
            saveIdealOrientationToUserDefaults(idealOrientations)
        }
        print("orientationDictionary\(orientationDictionary)")
    }

    func traverseNodes() {
        var actions: [SCNAction] = []
        takeReading(relativeOrientations: actualRotations)
        
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
            print("No Shoulder. Right node found.")
        }
        
        if let leftShoulderNode = modelHelper.getShoulderLeftNode() {
            let angle = quatToEuler(actualRotations[leftShoulderNode.name!]!)
            let animation = SCNAction.rotateTo(x: CGFloat(angle.x), y: CGFloat(angle.y), z: CGFloat(angle.z), duration: 0.5, usesShortestUnitArc: true)
            let backBend = SCNAction.customAction(duration: 0.5) {
                (node, elapsedTime) in leftShoulderNode.runAction(animation)}
            actions.append(backBend)
        } else {
            print("No Shoulder. Left node found.")
        }
        
        let rootNode = modelHelper.getRootNode()
        rootNode?.runAction(SCNAction.sequence(actions))
    }
    
    func takeReading(relativeOrientations: [String: simd_quatf]) {
        let result = calculatePostureScore(relativeOrientations: relativeOrientations)

        print("result: \(result)")
        let timestamp = Date()
//        readings[timestamp] = (score: result.score, graphData: result!.graphData)
        
        //Store readings in UserDefaults
//        saveReadingsToUserDefaults()
    }
    
    func saveReadingsToUserDefaults() {
        let readingsArray = readings.map { (timestamp, data) -> [String: Any] in
            return [
                "timestamp": timestamp.timeIntervalSince1970,
                "score": data.score,
                "graphData": data.graphData
            ]
        }
        
        // print("readingsArray: \(readingsArray)")
        
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
           // print("saved readings: \(savedReadings)")
        }
    }

    let idealSpinalStraightnessAngle: Float = 0.0
    let idealHunchAngle: Float = 0.0
    let idealShoulderBalanceAngle: Float = 0.0
    let idealMidBackPosition = simd_quatf(real: 0.9928279, imag: SIMD3<Float>(0.11949053, 0.0031463057, 0.002229631))
    let idealUpperBackPosition = simd_quatf(real: 0.98132086, imag: SIMD3<Float>(-0.19236962, 0.001164876, 0.0013690897))
    let idealLeftShoulderPosition = simd_quatf(real: 0.31320974, imag: SIMD3<Float>(0.6619291, -0.4412961, -0.5186592))
    let idealRightShoulderPosition = simd_quatf(real: 0.31320974, imag: SIMD3<Float>(0.6619291, 0.4412961, 0.5186592))
    let idealQuaternions: [String: simd_quatf] = ["MidBack": simd_quatf(real: 0.9928279, imag: SIMD3<Float>(0.11949053, 0.0031463057, 0.002229631)),
                                                  "UpperBack": simd_quatf(real: 0.98132086, imag: SIMD3<Float>(-0.19236962, 0.001164876, 0.0013690897)),
                                                  "Shoulder-Right": simd_quatf(real: 0.31320974, imag: SIMD3<Float>(0.6619291, 0.4412961, 0.5186592)),
                                                  "Shoulder-Left": simd_quatf(real: 0.31320974, imag: SIMD3<Float>(0.6619291, -0.4412961, -0.5186592))]

    func quaternionToEulerAngles(_ quat: simd_quatf) -> simd_float3 {
        let m = simd_matrix4x4(quat)
        let pitch = atan2(m[2][1], m[2][2])
        let roll  = atan2(m[2][0], sqrt(m[2][1] * m[2][1] + m[2][2] * m[2][2]))
        let yaw   = atan2(m[1][0], m[0][0])
        return simd_float3(pitch, roll, yaw)
    }

    func calculateSpinalStraightness(relativeOrientations: [String: simd_quatf]) -> Float {
        guard let spineMidQuat = relativeOrientations["MidBack"],
              let spineUpperQuat = relativeOrientations["UpperBack"] else {
            return -1
        }
        
        let midBackAngles = quaternionToEulerAngles(spineMidQuat * idealQuaternions["MidBack"]!.conjugate)
        let upperBackAngles = quaternionToEulerAngles(spineUpperQuat * idealQuaternions["UpperBack"]!.conjugate)
        
        
        let totalSpinalStraightnessAngle = abs(midBackAngles.z) + abs(upperBackAngles.z)

        return totalSpinalStraightnessAngle
    }

    func calculateHunchAngle(relativeOrientations: [String: simd_quatf]) -> Float {
        guard let spineMidQuat = relativeOrientations["MidBack"],
              let spineUpperQuat = relativeOrientations["UpperBack"] else {
            return -1
        }
        
        let midBackAngles = quaternionToEulerAngles(spineMidQuat * idealQuaternions["MidBack"]!.conjugate)
        let upperBackAngles = quaternionToEulerAngles(spineUpperQuat * idealQuaternions["UpperBack"]!.conjugate)
        print("MBA: \(midBackAngles)\nUBA: \(upperBackAngles)")
        
        let totalSpinalHunchAngle = abs(midBackAngles.x) + abs(upperBackAngles.x)

        return totalSpinalHunchAngle
    }

    func calculateShoulderBalance(relativeOrientations: [String: simd_quatf]) -> Float {
        guard let shoulderLeftQuat = relativeOrientations["Shoulder-Left"],
                let shoulderRightQuat = relativeOrientations["Shoulder-Right"] else {
            return -1
        }
        
        let shoulderLeftAngle = abs((shoulderLeftQuat * idealQuaternions["Shoulder-Left"]!.conjugate).angle)
        let shoulderRightAngle = abs((shoulderRightQuat * idealQuaternions["Shoulder-Right"]!.conjugate).angle)

        return (shoulderLeftAngle + shoulderRightAngle) / 2
    }

    func normalizeDeviation(_ activeAngle: Float, idealAngle: Float, maxDeviation: Float) -> Float {
        let deviation = abs(activeAngle - idealAngle)
        return min(deviation / maxDeviation, 1.0)
    }

    func calculatePostureScore(relativeOrientations: [String: simd_quatf]) -> (score: Float, graphData: [Float])? {
        let spinalStraightnessAngle = calculateSpinalStraightness(relativeOrientations: relativeOrientations)
        let hunchAngle = calculateHunchAngle(relativeOrientations: relativeOrientations)
        let shoulderBalanceAngle = calculateShoulderBalance(relativeOrientations: relativeOrientations)
        
        print("ss: \(spinalStraightnessAngle)")
        print("h: \(hunchAngle)")
        print("sb: \(shoulderBalanceAngle)")
        
        if spinalStraightnessAngle == -1 || hunchAngle == -1 || shoulderBalanceAngle == -1 {
            print("calculatePostureScore Error: angle not found")
            return nil
        }

        let normalizedSpinalStraightness =  1 - (normalizeDeviation(spinalStraightnessAngle, idealAngle: idealSpinalStraightnessAngle, maxDeviation: ((25.0 * .pi) / 180)))
        let normalizedHunch = 1 - (normalizeDeviation(hunchAngle, idealAngle: idealHunchAngle, maxDeviation: ((25.0 * .pi) / 180)))
        let normalizedShoulderBalance = 1 - (normalizeDeviation(shoulderBalanceAngle, idealAngle: idealShoulderBalanceAngle, maxDeviation: ((25.0 * .pi) / 180)))
        
        print("normalizedSpinalStraightness: \(normalizedSpinalStraightness)")
        print("hunchAngle: \(hunchAngle)")
        print("normalizedShoulderBalance: \(normalizedShoulderBalance)")
        
        let spinalStraightnessWeight: Float = 0.2
        let hunchWeight: Float = 0.4
        let shoulderBalanceWeight: Float = 0.4
        
        let finalScore = (normalizedSpinalStraightness * spinalStraightnessWeight) +
                         (normalizedHunch * hunchWeight) +
                         (normalizedShoulderBalance * shoulderBalanceWeight)
        
        print("finalScore\(finalScore)")

        let graphData: [Float] = [normalizedSpinalStraightness, normalizedHunch, normalizedShoulderBalance]
        
        score = finalScore
        return (finalScore, graphData)
    }
    func captureIdealOrientationData(from sensorDataProcessor: SensorDataProcessor) {
        // Create a dictionary to store the ideal orientation (as quaternions)
        isConfigured = true
    }

    // The function that saves the ideal orientation data
    func saveIdealOrientationToUserDefaults(_ idealOrientations: [String: simd_quatf]) {
        // Convert the quaternions to a format that can be saved (e.g., as arrays of floats)
        let savedData = idealOrientations.map { (boneName, quat) -> [String: Any] in
            return [
                "boneName": boneName,
                "quaternion": [quat.real, quat.imag.x, quat.imag.y, quat.imag.z]
            ]
        }
        
        // Store the data in UserDefaults
        UserDefaults.standard.set(savedData, forKey: "idealOrientations")
    }
}
