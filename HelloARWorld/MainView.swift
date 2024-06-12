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
        .onAppear {
            // Configure tab bar appearance to ensure it is always visible
            setupTabBarAppearance()
        }
    }
    
    // Function to ensure the tab bar remains visible
    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
