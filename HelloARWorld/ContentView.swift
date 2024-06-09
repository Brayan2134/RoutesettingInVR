import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var showModal = false // State property to control the display of the modal view. When true, the OptionsViewControllerWrapper is presented.
    @State private var selectedShape: ShapeType? // Keep track of a shape that the user intends to place on the screen. The user will tap the screen, but ViewController and ARViewContainer will take care of the AR logic.
    @State private var showHint = false // State property to track whether to display "Tap to place object". This will be active if the user clicked on an object (route hold) from the OptionsViewController.
    @State private var isARCoachActive: Bool = false // State property to track if ARCoachingOverlay is active. If so, no elements will work on screen.

    var body: some View {
        ZStack {
            // ARViewContainer with bindings to selectedShape, showHint, and isARCoachActive
            ARViewContainer(selectedShape: $selectedShape, showHint: $showHint, isARCoachActive: $isARCoachActive).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Display a hint if showHint is true
                if showHint {
                    Text("Tap to place object")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
                
                // Button to show the modal view
                Button(action: {
                    showModal = true
                }) {
                    Text("Add element")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isARCoachActive) // Disable button if ARCoachingOverlayView is active
                // Present the OptionsViewControllerWrapper as a sheet when showModal is true
                .sheet(isPresented: $showModal) {
                    OptionsViewControllerWrapper(selectedShape: $selectedShape, showHint: $showHint)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
