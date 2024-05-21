import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recognizer:))))
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            let location = recognizer.location(in: parent.arView)
            
            let results = parent.arView.hitTest(location, types: [.existingPlaneUsingExtent])
            if let result = results.first {
                let anchor = ARAnchor(name: "object", transform: result.worldTransform)
                parent.arView.session.add(anchor: anchor)
                
                let sphere = MeshResource.generateSphere(radius: 0.1)
                let material = SimpleMaterial(color: .red, isMetallic: true)
                let entity = ModelEntity(mesh: sphere, materials: [material])
                
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(entity)
                parent.arView.scene.addAnchor(anchorEntity)
            }
        }
    }
}
