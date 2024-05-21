import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
