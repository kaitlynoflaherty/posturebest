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
    var modelHelper = ModelHelper()
    
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
            print("\(indentation)Node: \(node.name ?? "Unnamed Node")")
            print("\(indentation)  Position: \(node.position)")
            print("\(indentation)  Rotation: \(node.rotation)")
            print("\(indentation)  Scale: \(node.scale)")
            
            // Recursively print child nodes
             for childNode in node.childNodes {
                printNodeHierarchy(node: childNode, depth: depth + 1)
            }
        }
    
    private func loadModel(into scene: SCNScene, context: Context) {
        guard let modelScene = SCNScene(named: "male.dae") else {
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

        scene.rootNode.addChildNode(skeletonNode)
        context.coordinator.modelNode = skeletonNode
        
        modelHelper.setRootNode(node: skeletonNode)
        
        // set nodes for live updating
        if let Human = scene.rootNode.childNode(withName: "HumanMale", recursively: true) {
            let lowerBackNode = Human.skinner?.skeleton?.childNode(withName: "LowerBack", recursively: true)!
            let midBackNode = Human.skinner?.skeleton?.childNode(withName: "MidBack", recursively: true)!
            let upperBackNode = Human.skinner?.skeleton?.childNode(withName: "UpperBack", recursively: true)!
            let shoulderRightNode = Human.skinner?.skeleton?.childNode(withName: "Shoulder-Right", recursively: true)!
            let shoulderLeftNode = Human.skinner?.skeleton?.childNode(withName: "Shoulder-Left", recursively: true)!

            modelHelper.setReferenceOrientation(boneName: "LowerBack", orientation: lowerBackNode!.simdWorldOrientation)
            modelHelper.setReferenceOrientation(boneName: "MidBack", orientation: midBackNode!.simdWorldOrientation)
            modelHelper.setReferenceOrientation(boneName: "UpperBack", orientation: upperBackNode!.simdWorldOrientation)
            modelHelper.setReferenceOrientation(boneName: "Shoulder-Right", orientation: shoulderRightNode!.simdWorldOrientation)
            modelHelper.setReferenceOrientation(boneName: "Shoulder-Left", orientation: shoulderLeftNode!.simdWorldOrientation)
            
            // math for left shoulder orientation adjustments
            print("midback orientation: \(upperBackNode!.simdOrientation)")
            print("lower back to mid back: \(upperBackNode!.simdWorldOrientation * midBackNode!.simdWorldOrientation.conjugate)")
            print("well, what gets hyou from this to that: \(upperBackNode!.simdOrientation * (upperBackNode!.simdWorldOrientation * midBackNode!.simdWorldOrientation.conjugate).conjugate)")
            let left = shoulderLeftNode!.simdWorldOrientation
            let upper = upperBackNode!.simdWorldOrientation
            
            let swappedLeftShoulder = simd_quatf(ix: left.imag.y, iy: -left.imag.z, iz: -left.imag.x, r: left.real)
            let swappedUpper = simd_quatf(ix: upper.imag.y, iy: -upper.imag.z, iz: -upper.imag.x, r: upper.real)
            
            let math = swappedLeftShoulder * (swappedUpper.conjugate)
            print("after math: \(math)")
            
            let final = shoulderLeftNode!.simdOrientation * math.conjugate
            
            print("final\(final)")

            modelHelper.setMidBackNode(node: midBackNode!)
            modelHelper.setUpperBackNode(node: upperBackNode!)
            modelHelper.setShoulderRightNode(node: shoulderRightNode!)
            modelHelper.setShoulderLeftNode(node: shoulderLeftNode!)
        } else {
            print("Human not found")
        }

//        printNodeHierarchy(node: scene.rootNode)

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
        directionalLightNode.look(at: SCNVector3(0, 0, 0))
        directionalLightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(directionalLightNode)
    }
    
    private func addCamera(to scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 3)
        cameraNode.look(at: SCNVector3(0, 1, 0))
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
