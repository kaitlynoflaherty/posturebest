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
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.white
        
        // Create and set up the scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        loadModel(into: scene)
        
        addLights(to: scene)
        
        addCamera(to: scene)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
    
    private func loadModel(into scene: SCNScene) {
        guard let modelScene = SCNScene(named: "human_woman.dae") else {
            print("Failed to load the model.")
            return
        }
        
        
        let modelNode = modelScene.rootNode
            modelNode.scale = SCNVector3(0.1, 0.1, 0.1) // Adjust scale as needed
            scene.rootNode.addChildNode(modelNode)
        
        // Adjust the camera position to fit the model
            fitCamera(to: modelNode, in: scene)
            print("Model loaded successfully!")
        
    }
    
    private func addLights(to scene: SCNScene) {
        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Directional light
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)
    }
}
