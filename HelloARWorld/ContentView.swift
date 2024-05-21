import SwiftUI

struct ContentView: View {
    // The main view of the app containing the AR view.
    var body: some View {
        ZStack {
            // ARViewContainer contains the AR view and manages AR interactions.
            ARViewContainer().edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    // Provides a preview for SwiftUI design tools.
    static var previews: some View {
        ContentView()
    }
}
