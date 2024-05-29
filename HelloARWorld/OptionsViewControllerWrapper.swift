import SwiftUI
import UIKit

struct OptionsViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var selectedShape: ShapeType?
    @Binding var showHint: Bool

    func makeUIViewController(context: Context) -> OptionsViewController {
        let viewController = OptionsViewController()
        viewController.selectedShape = { shape in
            self.selectedShape = shape
            self.showHint = true
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: OptionsViewController, context: Context) {}
}
