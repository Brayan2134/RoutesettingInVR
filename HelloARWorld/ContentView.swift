import SwiftUI

struct ContentView: View {
    let arViewContainer = ARViewContainer()
    
    var body: some View {
        VStack {
            arViewContainer
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button(action: {
                    arViewContainer.makeCoordinator().saveWorldMap()
                }) {
                    Text("Save World")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    arViewContainer.makeCoordinator().loadWorldMap()
                }) {
                    Text("Load World")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

