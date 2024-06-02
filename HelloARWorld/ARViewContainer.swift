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
    @Binding var isARCoachActive: Bool
    
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
         coachingOverlay.delegate = context.coordinator // Set delegate to handle coaching events
         coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         coachingOverlay.goal = .horizontalPlane
         arView.addSubview(coachingOverlay)
         
         context.coordinator.arView = arView

         // Add observer for snap to wall functionality
         NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.snapAllObjectsToWall), name: NSNotification.Name("SnapToWall"), object: nil)

         // Set AR session delegate to receive plane detection updates
         arView.session.delegate = context.coordinator

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
        Coordinator(selectedShape: $selectedShape, showHint: $showHint, isARCoachActive: $isARCoachActive)
    }
    
    // Coordinator to manage AR interactions and delegate methods.
    class Coordinator: NSObject, ARCoachingOverlayViewDelegate, ARSessionDelegate {
        @Binding var selectedShape: ShapeType?
        @Binding var showHint: Bool
        @Binding var isARCoachActive: Bool
        var arView: ARView?
        var detectedWalls: [ARPlaneAnchor] = []
        var existingObjects: [simd_float3] = [] // Store positions of existing objects
        
        init(selectedShape: Binding<ShapeType?>, showHint: Binding<Bool>, isARCoachActive: Binding<Bool>) {
                    self._selectedShape = selectedShape
                    self._showHint = showHint
                    self._isARCoachActive = isARCoachActive
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
                
                var position = simd_make_float3(result.worldTransform.columns.3)
                
                // Check for collisions and adjust position if necessary
                while isColliding(with: position, shape: shape) {
                    position.z += 0.2 // Adjust z-axis offset to avoid collision
                }
                
                let anchor = ARAnchor(name: "object", transform: float4x4(translation: position))
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
                
                // Store the position of the new object
                existingObjects.append(position)
                
                // Hide the hint after placing the object
                showHint = false
                selectedShape = nil
            } else {
                print("No hit test result found")
            }
        }
        
        // ARCoachingOverlayView delegate methods
        func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
            isARCoachActive = true // Set isARCoachActive to true when coaching overlay is active
        }

        func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
            isARCoachActive = false // Set isARCoachActive to false when coaching overlay is inactive
        }

        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            // Handle session reset request if needed.
        }
        
        // Function to check if a new position collides with any existing objects
        func isColliding(with position: simd_float3, shape: ShapeType) -> Bool {
            let collisionDistance: Float = 0.2 // Define a suitable collision distance
            for existingPosition in existingObjects {
                if distance(position, existingPosition) < collisionDistance {
                    return true
                }
            }
            return false
        }
        
        @objc func snapAllObjectsToWall() {
            guard let arView = arView else { return }
            guard let nearestWall = detectedWalls.first else { return } // Using the first detected wall
            
            // Get the wall's transform
            let wallTransform = nearestWall.transform
            let wallPosition = simd_make_float3(wallTransform.columns.3)
            
            // Iterate over all anchors in the scene
            for anchor in arView.scene.anchors {
                // Iterate over all entities attached to the anchor
                for entity in anchor.children {
                    if let modelEntity = entity as? ModelEntity {
                        // Snap entity to the wall plane
                        var transform = modelEntity.transform
                        transform.translation.x = wallPosition.x
                        transform.translation.y = wallPosition.y
                        transform.translation.z = wallPosition.z
                        modelEntity.transform = transform
                    }
                }
            }
        }
        
        // ARSessionDelegate method to track detected planes
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical {
                    detectedWalls.append(planeAnchor)
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

// Helper function to create a translation matrix
extension float4x4 {
    init(translation: simd_float3) {
        self = matrix_identity_float4x4
        self.columns.3 = simd_float4(translation, 1.0)
    }
}

