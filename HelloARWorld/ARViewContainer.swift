import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    // Shared instance for accessing ARViewContainer methods globally.
    static var shared = ARViewContainer()
    
    // AR view where the AR content is rendered.
    let arView = ARView(frame: .zero)
    
    // Creates the AR view.
    func makeUIView(context: Context) -> ARView {
        // Configure AR session.
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        // Start the AR session.
        arView.session.run(config)
        
        // Set up gesture recognizer for taps.
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recognizer:))))
        
        // Add AR coaching overlay to help users find planes.
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        return arView
    }
    
    // Updates the AR view (not used in this simple example).
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    // Creates the coordinator for handling AR session events and gestures.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class to handle AR session events and gestures.
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        // Handles tap gestures on the AR view.
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            let location = recognizer.location(in: parent.arView)
            print("Tap detected at location: \(location)")
            
            let results = parent.arView.hitTest(location, types: [.existingPlaneUsingExtent])
            if let result = results.first {
                print("Hit test result found: \(result)")
                let anchor = ARAnchor(name: "object", transform: result.worldTransform)
                parent.arView.session.add(anchor: anchor)
                
                // Create and place a red metallic sphere.
                do {
                    let sphere = MeshResource.generateSphere(radius: 0.1)
                    let material = SimpleMaterial(color: .red, isMetallic: true)
                    let entity = ModelEntity(mesh: sphere, materials: [material])
                    
                    let anchorEntity = AnchorEntity(anchor: anchor)
                    anchorEntity.addChild(entity)
                    parent.arView.scene.addAnchor(anchorEntity)
                } catch {
                    print("Failed to create or place sphere: \(error.localizedDescription)")
                }
            } else {
                print("No hit test result found")
            }
        }
    }
}
