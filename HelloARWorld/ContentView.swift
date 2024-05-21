import SwiftUI

struct ContentView: View {
    // State property to store the selected shape type.
    @State private var selectedShape: ShapeType = .sphere
    
    var body: some View {
        ZStack {
            // ARViewContainer manages the AR session and interactions.
            // It takes selectedShape as a binding to allow updates.
            ARViewContainer(selectedShape: $selectedShape).edgesIgnoringSafeArea(.all)
            
            // UI drawer with buttons for selecting different shapes.
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            // Update selectedShape to sphere.
                            selectedShape = .sphere
                        }) {
                            Text("Sphere")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: {
                            // Update selectedShape to box.
                            selectedShape = .box
                        }) {
                            Text("Box")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: {
                            // Update selectedShape to cylinder.
                            selectedShape = .cylinder
                        }) {
                            Text("Cylinder")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    // Provides a preview for SwiftUI design tools.
    static var previews: some View {
        ContentView()
    }
}
