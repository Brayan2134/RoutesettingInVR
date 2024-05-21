import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        arView.session.run(config)
        
        arView.session.delegate = self
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .vertical)
        if let firstResult = results.first {
            let anchor = AnchorEntity(raycastResult: firstResult)
            let box = ModelEntity(mesh: .generateBox(size: 0.1))
            box.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
            anchor.addChild(box)
            arView.scene.addAnchor(anchor)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Handle session updates if needed
    }
    
    func saveWorldMap() {
        arView.session.getCurrentWorldMap { worldMap, error in
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
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            print("World map loaded.")
        } catch {
            print("Error loading world map: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
