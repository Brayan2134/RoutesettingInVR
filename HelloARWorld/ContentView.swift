import SwiftUI

struct ContentView: View {
    @State private var selectedShape: ShapeType = .sphere
    
    var body: some View {
        ZStack {
            ARViewContainer(selectedShape: $selectedShape).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            selectedShape = .sphere
                        }) {
                            Text("Sphere")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: {
                            selectedShape = .box
                        }) {
                            Text("Box")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: {
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
    static var previews: some View {
        ContentView()
    }
}
