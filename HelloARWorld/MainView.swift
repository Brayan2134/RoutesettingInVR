import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            SocialView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
