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
        guard let modelScene = SCNScene(named: "new_man.dae") else {
            print("Failed to load the model.")
            return
        }

        guard let skeletonNode = modelScene.rootNode.childNodes.first else {
            print("No skeleton found.")
            return
        }

        // Ensure the mesh node is correctly referenced
        if let meshNode = skeletonNode.childNodes.last {
            meshNode.scale = SCNVector3(1.0, 1.0, 1.0)
            meshNode.eulerAngles.x = -.pi / 2
            meshNode.eulerAngles.y = .pi
            
            // Center the meshNode
            let (min, max) = meshNode.boundingBox
            let center = SCNVector3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
            meshNode.position = SCNVector3(-center.x, -center.y, -center.z)
            meshNode.pivot = SCNMatrix4MakeTranslation(-center.x, -center.y, -center.z)

            // Add the skeleton to the scene
            scene.rootNode.addChildNode(skeletonNode)
            context.coordinator.modelNode = skeletonNode // Store reference to skeleton node
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
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 5) // Adjust the position to fit the model better
        cameraNode.look(at: SCNVector3(0, 0, 0)) // Make the camera look at the center of the scene
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
            self.modelNode = nil
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let modelNode = modelNode else { return }

            let translation = gesture.translation(in: gesture.view)

            if gesture.state == .changed {
                // Get the back node
                guard let backNode = modelNode.childNode(withName: "Back", recursively: true) else { return }
                
                // Calculate the offset from the back node
                let offset = SCNVector3(x: modelNode.position.x - backNode.position.x,
                                         y: modelNode.position.y - backNode.position.y,
                                         z: modelNode.position.z - backNode.position.z)
                
                // Rotate the model around the back node's Y-axis
                let rotationAmount = Float(translation.x) * 0.01
                modelNode.eulerAngles.y += rotationAmount
                
                // Update model's position based on the new rotation around the back node
                let rotatedOffset = SCNVector3(
                    x: offset.x * cos(rotationAmount) - offset.z * sin(rotationAmount),
                    y: offset.y,
                    z: offset.x * sin(rotationAmount) + offset.z * cos(rotationAmount)
                )
                
                modelNode.position = SCNVector3(
                    backNode.position.x + rotatedOffset.x,
                    backNode.position.y + rotatedOffset.y,
                    backNode.position.z + rotatedOffset.z
                )
                
                // Reset the translation after applying it
                gesture.setTranslation(.zero, in: gesture.view)
            }
        }
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
