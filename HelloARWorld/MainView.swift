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
    
    // Function to ensure the tab bar remains visible and styled
    func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Customize background color
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        // Customize selected item appearance
        let selectedAppearance = UITabBarItemAppearance()
        selectedAppearance.selected.iconColor = UIColor.systemBlue
        selectedAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        // Customize normal item appearance
        let normalAppearance = UITabBarItemAppearance()
        normalAppearance.normal.iconColor = UIColor.gray
        normalAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // Apply the custom appearances to the tab bar
        tabBarAppearance.stackedLayoutAppearance = normalAppearance
        tabBarAppearance.stackedLayoutAppearance = selectedAppearance

        // Apply the appearance to the tab bar
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        
        // Optional: Customize shadow
        tabBarAppearance.shadowColor = UIColor.lightGray
        tabBarAppearance.shadowImage = UIImage()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
