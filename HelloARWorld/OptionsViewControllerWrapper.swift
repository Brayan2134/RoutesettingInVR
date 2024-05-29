import SwiftUI
import UIKit

struct OptionsViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var selectedShape: ShapeType

    func makeUIViewController(context: Context) -> OptionsViewController {
        let viewController = OptionsViewController()
        viewController.selectedShape = { shape in
            self.selectedShape = shape
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: OptionsViewController, context: Context) {}
}
