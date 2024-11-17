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
    static var copiedNode: SCNNode?
        
        init() {
            rootNode = SCNNode()
        }
        
        func setNode(node: SCNNode) {
            let clonedNode = node
            Torso3DUtil.copiedNode = clonedNode
            print("Node copied and stored: \(clonedNode)")
        }
        
        func getNode() -> SCNNode? {
            return Torso3DUtil.copiedNode
        }
}
