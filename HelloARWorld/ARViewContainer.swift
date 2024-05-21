import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
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
            super.init()
            parent.arView.session.delegate = self
        }
        
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            let location = recognizer.location(in: parent.arView)
            let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .vertical)
            if let firstResult = results.first {
                let anchor = AnchorEntity(world: firstResult.worldTransform) // Update this line to use worldTransform
                let box = ModelEntity(mesh: .generateBox(size: 0.1))
                box.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
                anchor.addChild(box)
                parent.arView.scene.addAnchor(anchor)
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Handle session updates if needed
        }
        
        func saveWorldMap() {
            parent.arView.session.getCurrentWorldMap { worldMap, error in
                guard let map = worldMap else { print("Error saving world map: \(error?.localizedDescription ?? "")"); return }
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    try data.write(to: self.getDocumentsDirectory().appendingPathComponent("worldMap.arexperience"))
                    print("World map saved.")
                } catch {
                    print("Error saving world map: \(error.localizedDescription)")
                }
            }
        }
        
        func loadWorldMap() {
            do {
                let data = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("worldMap.arexperience"))
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else { return }
                let config = ARWorldTrackingConfiguration()
                config.initialWorldMap = worldMap
                config.planeDetection = [.vertical]
                parent.arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
                print("World map loaded.")
            } catch {
                print("Error loading world map: \(error.localizedDescription)")
            }
        }
        
        func getDocumentsDirectory() -> URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    }
}

struct ARViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ARViewContainer()
    }
}

