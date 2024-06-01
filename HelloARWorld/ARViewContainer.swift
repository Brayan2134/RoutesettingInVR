import SwiftUI
import RealityKit
import ARKit

// Enum to define different shape types.
enum ShapeType {
    case sphere
    case box
    case cylinder
}

struct ARViewContainer: UIViewRepresentable {
    // Binding properties to keep track of the selected shape and hint visibility.
    @Binding var selectedShape: ShapeType?
    @Binding var showHint: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session for horizontal and vertical plane detection.
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Add gesture recognizer for tap interactions.
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recognizer:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Add ARCoachingOverlayView to guide users for better plane detection.
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        context.coordinator.arView = arView
        
        // Add observer for snap to wall functionality
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.snapAllObjectsToWall), name: NSNotification.Name("SnapToWall"), object: nil)

        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // This function can be used to update the view when state changes.
        // Currently, it does not need to perform any updates.
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        // Pause the AR session when the view is being dismantled
        uiView.session.pause()
    }
    
    func makeCoordinator() -> Coordinator {
        // Create and return a coordinator to handle AR session events and gestures.
        Coordinator(self, selectedShape: $selectedShape, showHint: $showHint)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        @Binding var selectedShape: ShapeType?
        @Binding var showHint: Bool
        var arView: ARView?
        
        init(_ parent: ARViewContainer, selectedShape: Binding<ShapeType?>, showHint: Binding<Bool>) {
            self.parent = parent
            self._selectedShape = selectedShape
            self._showHint = showHint
        }
        
        // Handle tap gestures on the AR view.
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = recognizer.location(in: arView)
            print("Tap detected at location: \(location)")
            
            // Perform hit test to find real-world surfaces.
            let results = arView.hitTest(location, types: [.existingPlaneUsingExtent])
            if let result = results.first, let shape = selectedShape {
                print("Hit test result found: \(result)")
                let anchor = ARAnchor(name: "object", transform: result.worldTransform)
                arView.session.add(anchor: anchor)
                
                let entity: ModelEntity
                // Create different shapes based on the selected shape type.
                switch shape {
                case .sphere:
                    let sphere = MeshResource.generateSphere(radius: 0.1)
                    entity = ModelEntity(mesh: sphere)
                case .box:
                    let box = MeshResource.generateBox(size: 0.1)
                    entity = ModelEntity(mesh: box)
                case .cylinder:
                    // Manually create a cylinder mesh.
                    entity = generateCylinder(radius: 0.05, height: 0.1)
                }
                
                // Apply red metallic material to the entity.
                let material = SimpleMaterial(color: .red, isMetallic: true)
                entity.model?.materials = [material]
                
                // Create an anchor entity and add the shape entity to it.
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(entity)
                arView.scene.addAnchor(anchorEntity)
                
                // Hide the hint after placing the object
                showHint = false
                selectedShape = nil
            } else {
                print("No hit test result found")
            }
        }
        
        @objc func snapAllObjectsToWall() {
            guard let arView = arView else { return }
            
            for anchor in arView.scene.anchors {
                for entity in anchor.children {
                    if let modelEntity = entity as? ModelEntity {
                        var transform = modelEntity.transform
                        transform.translation.z = 0
                        modelEntity.transform = transform
                    }
                }
            }
        }
        
        // Function to generate a custom cylinder mesh.
        func generateCylinder(radius: Float, height: Float) -> ModelEntity {
            var vertices: [SIMD3<Float>] = []
            var indices: [UInt32] = []
            
            let segments: Int = 36
            let angle: Float = 2 * .pi / Float(segments)
            
            // Generate vertices for the cylinder.
            for i in 0..<segments {
                let x = radius * cos(Float(i) * angle)
                let z = radius * sin(Float(i) * angle)
                vertices.append(SIMD3<Float>(x, height / 2, z))
                vertices.append(SIMD3<Float>(x, -height / 2, z))
            }
            
            // Generate indices for the cylinder faces.
            for i in 0..<segments {
                let nextIndex = (i + 1) % segments
                indices.append(contentsOf: [
                    UInt32(2 * i), UInt32(2 * nextIndex), UInt32(2 * i + 1),
                    UInt32(2 * nextIndex), UInt32(2 * nextIndex + 1), UInt32(2 * i + 1)
                ])
            }
            
            // Create mesh descriptor and mesh resource from the vertices and indices.
            var meshDescriptor = MeshDescriptor(name: "cylinder")
            meshDescriptor.positions = MeshBuffer(vertices)
            meshDescriptor.primitives = .triangles(indices)
            
            let mesh = try! MeshResource.generate(from: [meshDescriptor])
            return ModelEntity(mesh: mesh)
        }
    }
}
