

import SwiftUI
import SceneKit

struct Model3DView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = false
        sceneView.backgroundColor = UIColor(hex: "#374663")
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        loadModel(into: scene, context: context)
        printNodeHierarchy(node: scene.rootNode)
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

        // Ensure the mesh node is correctly referenced
        if let meshNode = skeletonNode.childNodes.last {
            // Scale the mesh node as needed
            // Instead of resetting all rotations, just move the mesh node
                    // Calculate the center of the mesh node (bounding box center)
                    let (min, max) = meshNode.boundingBox
                    let center = SCNVector3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
                    print("Center of Mesh: \(center)")

                    // Move the mesh node to the origin
                    meshNode.position = SCNVector3(-center.x, -center.y, -center.z)
                    skeletonNode.position = SCNVector3(-center.x, -center.y, -center.z)
                    
                    // Optionally, reset its pivot to the center (this is not essential to the fix)
                    // meshNode.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)

                    // Don't touch the skeleton node's rotation to preserve its pose

                    // Add the skeleton node to the scene
                    scene.rootNode.addChildNode(skeletonNode)
                    context.coordinator.modelNode = skeletonNode // Store reference to the skeleton node
                    printNodeHierarchy(node: scene.rootNode)
        
                   
            
        } else {
            print("No mesh node found in the skeleton.")
        }

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
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func resetRotations(for node: SCNNode) {
        node.rotation = SCNVector4(0, 0, 1, 0)  // Identity rotation
        for child in node.childNodes {
            resetRotations(for: child)  // Recursively reset all child nodes
        }
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
            let rotationAmount = Float(translation.x) * 0.005 // Sensitivity of rotation

            if gesture.state == .changed {
                // Apply rotation around the Y-axis (modelNode's local Y-axis)
                modelNode.eulerAngles.y += rotationAmount

                // Reset the translation after applying it
                gesture.setTranslation(.zero, in: gesture.view)
            }
        }
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No updates needed in this case
    }
}
