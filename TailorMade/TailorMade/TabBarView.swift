import SwiftUI

struct TabBarView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                ExplorePage()
            }
            .tabItem {
                Label("Explore", systemImage: "magnifyingglass.circle")
            }
            
            NavigationView {
                SwipePage()
            }
            .tabItem {
                Label("Swipe", systemImage: "arrowshape.bounce.right.fill")
            }
            
            NavigationView {
                UploadPage()
            }
            .tabItem {
                Label("Post", systemImage: "square.and.arrow.up")
            }
            
            NavigationView {
                ProfilePage()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            
            NavigationView {
                ConversationsListView()
            }
            .tabItem {
                Label("Messages", systemImage: "rectangle.and.pencil.and.ellipsis")
            }
            
            NavigationView {
                NotificationsView()
            }
            .tabItem {
                Label("Notifications", systemImage: "bell")
            }
            
            NavigationView {
                DrawingGalleryView()
            }
            .tabItem {
                Label("Drawing Studio", systemImage: "paintbrush.pointed.fill")
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
