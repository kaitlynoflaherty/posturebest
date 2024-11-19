//
//  Torso3DView.swift
//  posturebest
//
//  Created by Madeline Coco on 10/16/24.
//

import SwiftUI
import SceneKit

struct Model3DView: UIViewRepresentable {
    var sensorDataProcessor = SensorDataProcessor()
    var bleManager = BLEManager()
    var torso3DUtil = Torso3DUtil()
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = false
        sceneView.backgroundColor = UIColor(hex: "#374663")
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        loadModel(into: scene, context: context)
        addLights(to: scene)
        addCamera(to: scene)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        return sceneView
    }
    
    func printNodeHierarchy(node: SCNNode, depth: Int = 0) {
        let indentation = String(repeating: "  ", count: depth)
        
        // Print node details
//        print("\(indentation)Node: \(node.name ?? "Unnamed Node")")
//        print("\(indentation)  Position: \(node.position)")
//        print("\(indentation)  Rotation: \(node.rotation)")
//        print("\(indentation)  Scale: \(node.scale)")
        
        // Recursively print child nodes
//         for childNode in node.childNodes {
//            printNodeHierarchy(node: childNode, depth: depth + 1)
//        }
    }
    
    private func loadModel(into scene: SCNScene, context: Context) {
        guard let modelScene = SCNScene(named: "male-new.dae") else {
            print("Failed to load the model.")
            return
        }

        // Get the root node of the model scene
        guard let skeletonNode = modelScene.rootNode.childNodes.first else {
            print("No skeleton found.")
            return
        }
        
        //Fix from upside down imported position
        skeletonNode.eulerAngles.y = .pi
        
//        // Calculate the bounding box and center of the skeletonNode
//        let (min, max) = skeletonNode.boundingBox
//        let center = SCNVector3(
//            (min.x + max.x) / 2,
//            (min.y + max.y) / 2,
//            (min.z + max.z) / 2
//        )
//        print("Center of Skeleton: \(center)")
//
//        skeletonNode.position = SCNVector3(-center.x, -center.y - 1, -center.z)

        scene.rootNode.addChildNode(skeletonNode)
        context.coordinator.modelNode = skeletonNode

        // Print the node hierarchy for debugging
//        printNodeHierarchy(node: scene.rootNode)
                
//         tests if change in orientation works (it does)
        if let Human = scene.rootNode.childNode(withName: "HumanMale", recursively: true) {
//            print("lower back node found: \(lowerBackNode.simdOrientation)")
//            print("lower back node found world: \(lowerBackNode.simdWorldOrientation)")
            let lowerBackNode = Human.skinner?.skeleton?.childNode(withName: "LowerBack", recursively: true)!
            torso3DUtil.setReferenceOrientation(orientation: lowerBackNode!.simdWorldOrientation)

            
            let midBackNode = Human.skinner?.skeleton?.childNode(withName: "MidBack", recursively: true)!
//            midBackNode!.rotate = 0.75
//            print("mid back: \(midBackNode?.simdWorldOrientation)")
//
            let upperBackNode = (Human.skinner?.skeleton?.childNode(withName: "UpperBack", recursively: true))!
//            upperBackNode!.rotation.x = 0.75
//            print("upper back: \(upperBackNode.simdWorldOrientation)")
//
//            print("Human Male: \(midBackNode.skinner?.skeleton?.childNodes)")
            torso3DUtil.setMidBackNode(node: midBackNode!)
            torso3DUtil.setUpperBackNode(node: upperBackNode)
        } else {
            print("Hips node not found")
        }
//        if let upperBackNode = scene.rootNode.childNode(withName: "UpperBack", recursively: true) {
//            upperBackNode.rotation.z = 0.75
//
////            torso3DUtil.setNode(node: upperBackNode)
//        } else {
//            print("upper back node not found")
//        }
        

        print("Model loaded successfully!")
    }
    

    private func addLights(to scene: SCNScene) {
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.darkGray
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.color = UIColor.white
        let directionalLightNode = SCNNode()
        directionalLightNode.light = directionalLight
        directionalLightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(directionalLightNode)
    }
    
    private func addCamera(to scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 1.2, z: 2)
        cameraNode.look(at: SCNVector3(0, 1.2, 0))
        cameraNode.camera?.fieldOfView = 45
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func rotateSkeleton(node: SCNNode, by angle: Float, around axis: SCNVector3) {
            node.rotation = SCNVector4(axis.x, axis.y, axis.z, angle)
        }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: Model3DView
        var modelNode: SCNNode?

        init(_ parent: Model3DView) {
            self.parent = parent
            self.modelNode = nil
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let modelNode = modelNode else { return }

            let translation = gesture.translation(in: gesture.view)
            let rotationAmount = Float(translation.x) * 0.005

            if gesture.state == .changed {
                modelNode.eulerAngles.y += rotationAmount

                gesture.setTranslation(.zero, in: gesture.view)
            }
        }
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No updates needed in this case
    }
}
