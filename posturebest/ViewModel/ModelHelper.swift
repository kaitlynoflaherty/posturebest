//
//  ModelHelper.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 11/19/24.
//

import Foundation
import SceneKit

class ModelHelper {
    var rootNode: SCNNode
    static var upperNode: SCNNode?
    static var midNode: SCNNode?
    static var referenceOrientation: simd_quatf?
        
        init() {
            rootNode = SCNNode()
        }
        
        func setUpperBackNode(node: SCNNode) {
            let clonedNode = node
            ModelHelper.upperNode = clonedNode
        }
    
        func setMidBackNode(node: SCNNode) {
            let clonedNode = node
            ModelHelper.midNode = clonedNode
        }
    
    
        func getUpperNode() -> SCNNode? {
            return ModelHelper.upperNode
        }
    
        func getMidNode() -> SCNNode? {
            return ModelHelper.midNode
        }

        
        func setReferenceOrientation(orientation: simd_quatf) {
            let referenceOrientation = orientation
            ModelHelper.referenceOrientation = referenceOrientation
        }

        func getReferenceOrientation() -> simd_quatf {
            return ModelHelper.referenceOrientation!
        }
}

