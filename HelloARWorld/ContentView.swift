import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var showModal = false
    @State private var selectedShape: ShapeType = .sphere // Default shape

    var body: some View {
        ZStack {
            ARViewContainer(selectedShape: $selectedShape).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
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
                    OptionsViewControllerWrapper(selectedShape: $selectedShape)
                }
            }
        }
    }
}
