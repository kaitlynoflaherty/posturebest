//
//  ModelHelper.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 11/19/24.
//

import Foundation
import SceneKit

class ModelHelper {
    var node: SCNNode
    static var rootNode: SCNNode?
    static var upperNode: SCNNode?
    static var midNode: SCNNode?
    static var shoulderRight: SCNNode?
    static var referenceOrientations: [String : simd_quatf] = [:]
        
        init() {
            node = SCNNode()
        }
    
        func setRootNode(node: SCNNode) {
            let clonedNode = node
            ModelHelper.rootNode = clonedNode
        }
        
        func setUpperBackNode(node: SCNNode) {
            let clonedNode = node
            ModelHelper.upperNode = clonedNode
        }
    
        func setMidBackNode(node: SCNNode) {
            let clonedNode = node
            ModelHelper.midNode = clonedNode
        }
        func setShoulderRightNode(node: SCNNode) {
            let clonedNode = node
            ModelHelper.shoulderRight = clonedNode
        }

        func getShoulderRightNode() -> SCNNode? {
            return ModelHelper.shoulderRight
        }
    
        func getRootNode() -> SCNNode? {
            return ModelHelper.rootNode
        }
    
        func getUpperNode() -> SCNNode? {
            return ModelHelper.upperNode
        }
    
        func getMidNode() -> SCNNode? {
            return ModelHelper.midNode
        }

        
    func setReferenceOrientation(boneName: String, orientation: simd_quatf) {
        let referenceOrientation = orientation
        ModelHelper.referenceOrientations[boneName] = referenceOrientation
        }

    func getReferenceOrientation(boneName: String) -> simd_quatf {
        return ModelHelper.referenceOrientations[boneName]!
        }
}

