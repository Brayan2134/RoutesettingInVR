import SwiftUI
import RealityKit
import ARKit

enum ShapeType {
    case sphere
    case box
    case cylinder
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedShape: ShapeType
    
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recognizer:))))
        
        // Add ARCoachingOverlayView
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, selectedShape: $selectedShape)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        @Binding var selectedShape: ShapeType
        
        init(_ parent: ARViewContainer, selectedShape: Binding<ShapeType>) {
            self.parent = parent
            self._selectedShape = selectedShape
        }
        
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            let location = recognizer.location(in: parent.arView)
            print("Tap detected at location: \(location)")
            
            let results = parent.arView.hitTest(location, types: [.existingPlaneUsingExtent])
            if let result = results.first {
                print("Hit test result found: \(result)")
                let anchor = ARAnchor(name: "object", transform: result.worldTransform)
                parent.arView.session.add(anchor: anchor)
                
                do {
                    let entity: ModelEntity
                    switch selectedShape {
                    case .sphere:
                        let sphere = MeshResource.generateSphere(radius: 0.1)
                        entity = ModelEntity(mesh: sphere)
                    case .box:
                        let box = MeshResource.generateBox(size: 0.1)
                        entity = ModelEntity(mesh: box)
                    case .cylinder:
                        // Manually create a cylinder mesh
                        entity = generateCylinder(radius: 0.05, height: 0.1)
                    }
                    
                    let material = SimpleMaterial(color: .red, isMetallic: true)
                    entity.model?.materials = [material]
                    
                    let anchorEntity = AnchorEntity(anchor: anchor)
                    anchorEntity.addChild(entity)
                    parent.arView.scene.addAnchor(anchorEntity)
                } catch {
                    print("Failed to create or place shape: \(error.localizedDescription)")
                }
            } else {
                print("No hit test result found")
            }
        }
        
        func generateCylinder(radius: Float, height: Float) -> ModelEntity {
            var vertices: [SIMD3<Float>] = []
            var indices: [UInt32] = []

            let segments: Int = 36
            let angle: Float = 2 * .pi / Float(segments)
            
            for i in 0..<segments {
                let x = radius * cos(Float(i) * angle)
                let z = radius * sin(Float(i) * angle)
                vertices.append(SIMD3<Float>(x, height / 2, z))
                vertices.append(SIMD3<Float>(x, -height / 2, z))
            }
            
            for i in 0..<segments {
                let nextIndex = (i + 1) % segments
                indices.append(contentsOf: [
                    UInt32(2 * i), UInt32(2 * nextIndex), UInt32(2 * i + 1),
                    UInt32(2 * nextIndex), UInt32(2 * nextIndex + 1), UInt32(2 * i + 1)
                ])
            }
            
            var meshDescriptor = MeshDescriptor(name: "cylinder")
            meshDescriptor.positions = MeshBuffer(vertices)
            meshDescriptor.primitives = .triangles(indices)
            
            let mesh = try! MeshResource.generate(from: [meshDescriptor])
            return ModelEntity(mesh: mesh)
        }
    }
}
