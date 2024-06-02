import SwiftUI
import UIKit

struct OptionsViewControllerWrapper: UIViewControllerRepresentable {
    // Bindings to pass the selected shape and hint visibility state back to ContentView
    @Binding var selectedShape: ShapeType?
    @Binding var showHint: Bool

    func makeUIViewController(context: Context) -> OptionsViewController {
        let viewController = OptionsViewController()
        // Closure to update the selected shape and show the hint
        viewController.selectedShape = { shape in
            self.selectedShape = shape
            self.showHint = true
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: OptionsViewController, context: Context) {}
}
