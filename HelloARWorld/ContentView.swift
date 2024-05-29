import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var showModal = false
    @State private var selectedShape: ShapeType?
    @State private var showHint = false

    var body: some View {
        ZStack {
            ARViewContainer(selectedShape: $selectedShape, showHint: $showHint).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if showHint {
                    Text("Tap to place object")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
                
                Button(action: {
                    showModal = true
                }) {
                    Text("Show Options")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showModal) {
                    OptionsViewControllerWrapper(selectedShape: $selectedShape, showHint: $showHint)
                }
            }
        }
    }
}
