//
//  Torso3DView.swift
//  posturebest
//
//  Created by Madeline Coco on 10/16/24.
//

import SwiftUI
import SceneKit

struct Model3DView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = false
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
    
    private func loadModel(into scene: SCNScene, context: Context) {
        guard let modelScene = SCNScene(named: "human_woman.dae") else {
            print("Failed to load the model.")
            return
        }
        
            if let modelNode = modelScene.rootNode.childNodes.first {
                modelNode.scale = SCNVector3(1.0, 1.0, 1.0)
                
                // Rotate model to face front
                modelNode.eulerAngles.x = -.pi / 2

                // Calculate bounding box and center the model
                let (min, max) = modelNode.boundingBox
                let center = SCNVector3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
                modelNode.position = SCNVector3(-center.x, -center.y, -center.z)

                
                scene.rootNode.addChildNode(modelNode)
                context.coordinator.modelNode = modelNode
        }
        
        // Adjust the camera position to fit the model
        print("Model loaded successfully!")
        
    }
    
    private func addLights(to scene: SCNScene) {
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
        scene.rootNode.addChildNode(cameraNode)
    }
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
    class Coordinator: NSObject {
            var parent: Model3DView
            var modelNode: SCNNode?

            init(_ parent: Model3DView) {
                self.parent = parent
            }
            
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let modelNode = modelNode else { return }
            
            let translation = gesture.translation(in: gesture.view)
            let rotationAmount = Float(translation.x) * 0.01

            // Y-axis rotation
            modelNode.eulerAngles.y += rotationAmount
            gesture.setTranslation(.zero, in: gesture.view)
            }
        }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
        
}
