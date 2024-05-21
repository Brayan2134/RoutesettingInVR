import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        arView.session.delegate = self
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.hitTest(location, types: [.existingPlaneUsingExtent])
        if let result = results.first {
            let anchor = ARAnchor(name: "object", transform: result.worldTransform)
            arView.session.add(anchor: anchor)
            
            let entity = try! Entity.load(named: "ship")
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(entity)
            arView.scene.addAnchor(anchorEntity)
        }
    }
}
