import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct Post: Identifiable,Decodable, Hashable {
    var id = UUID()
    var pid: String
    var imageUrl: String
    var userId: String
    var likes: Int
    var commentCount: Int

    
    init(pid: String, imageUrl: String, userId: String, likes: Int, commentCount: Int) {
        self.pid = pid
        self.imageUrl = imageUrl
        self.userId = userId
        self.likes = likes
        self.commentCount = commentCount
    }
}

struct Story: Identifiable,Decodable, Hashable {
    var id = UUID()
    var pid: String
    var imageUrl: String
    var userId: String

    
    init(pid: String, imageUrl: String, userId: String) {
        self.pid = pid
        self.imageUrl = imageUrl
        self.userId = userId
    }
}

struct Comment: Identifiable {
    var id = UUID()
    var commentId: String
    var userId: String
    var text: String
    var username: String
}

struct ProfilePage: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var explore: ExplorePageViewModel
    @State private var userPosts: [Post] = []
    
    var postsCount: Int {
        userPosts.count
    }

    var body: some View {
        let user = viewModel.currentUser
        let searchUser = explore.searchedUserID
        
        if let currentUser = user {
            NavigationView {
                ScrollView {
                    VStack {
                        // Profile Information
                        ProfileHeaderView(user: currentUser, postsCount: postsCount, followersCount: 1)
                        
                        // User Posts Feed
                        LazyVStack(spacing: 0) {
                            ForEach(userPosts) { post in
                                PostView(post: post)
                            }
                        }
                    }
                }
                .navigationBarTitle(currentUser.Username, displayMode: .inline)
                .navigationBarItems(leading:
                    NavigationLink(destination: SettingsPage()) {
                        Image(systemName: "gear")
                            .font(.title)
                    },
                    trailing:
                    NavigationLink(destination: CollectionsPage()) {
                        Image(systemName: "folder")
                            .font(.title)
                    }
                )
                .onAppear {
                    // Perform actions to refresh data
                    Task {
                        await viewModel.fetchUser()
                        if let userId = searchUser {
                            await fetchUserPosts(userId: userId)
                        } else {
                            await fetchUserPosts(userId: currentUser.id)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    func fetchUserPosts(userId: String) async {
        do {
            let db = Firestore.firestore()
            let postsQuery = try await db.collection("users").document(userId).collection("posts").getDocuments()

            userPosts = try postsQuery.documents.compactMap { document in
                guard
                    let imageUrl = document["imageUrl"] as? String,
                    let userId = document["userId"] as? String,
                    let likes = document["likes"] as? Int,
                    let commentCount = document["commentCount"] as? Int,
                    let pid = document.documentID as? String
                else {
                    return nil
                }

                return Post(
                    pid: pid,
                    imageUrl: imageUrl,
                    userId: userId,
                    likes: likes,
                    commentCount: commentCount
                )
            }

        } catch {
            print("Error fetching user posts: \(error.localizedDescription)")
        }
    }
}

struct ProfileHeaderView: View {
    
    var user: User
    var postsCount: Int
    var followersCount: Int
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: user.profileImageUrl)) // Accessing profile image URL directly from user object
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
            
            Text(user.fullname) // Accessing full name directly from user object
                .font(.headline)
                .padding(.top, 8)
            
            HStack(spacing: 16) {
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(postsCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 2)
                    Text("Posts")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                
                Spacer()
            }
            .padding(.top, 8)
            
            Text(user.bio) // Accessing bio directly from user object
                .foregroundColor(.gray)
                .padding(.top, 8)
                .padding(.horizontal, 20)
            
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white) // Optional: Add a background color
    }
}


struct PostView: View {
    @State private var isPresented: Bool = false
    var post: Post
    
    var body: some View {
        NavigationLink(destination: CombinedInstagramPostView(post: post)) {
                    VStack(alignment: .leading, spacing: 8) {
                        WebImage(url: URL(string: post.imageUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                        
                        Divider()
                    }
                    .padding([.leading, .trailing, .bottom])
                }
                .buttonStyle(PlainButtonStyle())
    }
}

//struct InstagramProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilePage()
//    }
//}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct SavedFolderView: View {
    var body: some View {
        Text("Saved Folder View")
    }
}
