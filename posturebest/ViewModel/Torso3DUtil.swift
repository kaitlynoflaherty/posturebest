//
//  Torso3DUtil.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 11/14/24.
//

import Foundation
import SceneKit

class Torso3DUtil {
    var rootNode: SCNNode
    static var upperNode: SCNNode?
    static var midNode: SCNNode?
    static var referenceOrientation: simd_quatf?
        
        init() {
            rootNode = SCNNode()
        }
        
        func setUpperBackNode(node: SCNNode) {
            let clonedNode = node
            Torso3DUtil.upperNode = clonedNode
//            print("Node copied and stored: \(clonedNode)")
        }
    
        func setMidBackNode(node: SCNNode) {
            let clonedNode = node
            Torso3DUtil.midNode = clonedNode
//            print("Node copied and stored: \(clonedNode)")
        }
    
    
        func getUpperNode() -> SCNNode? {
            return Torso3DUtil.upperNode
        }
    
        func getMidNode() -> SCNNode? {
            return Torso3DUtil.midNode
        }

        
        func setReferenceOrientation(orientation: simd_quatf) {
            let referenceOrientation = orientation
            Torso3DUtil.referenceOrientation = referenceOrientation
        }

        func getReferenceOrientation() -> simd_quatf {
            return Torso3DUtil.referenceOrientation!
        }
}
