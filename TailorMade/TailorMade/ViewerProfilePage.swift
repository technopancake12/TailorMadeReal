import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct SelectedProfilePage: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var user: User? // Store the selected user
    @State private var userPosts: [Post] = []
    @Binding var selectedUserID: String
    
    var postsCount: Int {
        userPosts.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Profile Information
                    if let user = user {
                        ViewerProfileHeaderView(user: user, postsCount: postsCount)
                    } else {
                        Text("Loading user profile...")
                            .padding()
                    }
                    
                    // User Posts Feed
                    LazyVStack(spacing: 0) {
                        ForEach(userPosts) { post in
                            ViewerPostView(post: post)
                        }
                    }
                }
            }
            .navigationBarTitle("User", displayMode: .inline)
            .onAppear {
                // Fetch user posts and user data when the view appears
                fetchUserPosts(userId: selectedUserID)
                fetchUserIdFromUsername(username: selectedUserID)
            }
        }
    }

    func fetchUserPosts(userId: String) {
        // Fetch user posts based on the provided user ID
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user posts: \(error.localizedDescription)")
                return
            }
            
            self.userPosts = snapshot?.documents.compactMap { document in
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
            } ?? []
        }
    }
    func fetchUserIdFromUsername(username: String) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        
        // Query Firestore for the user document with the given username
        usersRef.whereField("Username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            
            // Assuming username is unique, there should be only one document
            if let document = documents.first {
                let userId = document.documentID
                let userRef = db.collection("users").document(userId)
                // Use the found userId as needed
                print("User ID for \(username): \(userId)")
                
                // You can then pass this userId to other functions or update your view state
                self.selectedUserID = userId
                Task {
                    do {
                        if let document = try? await userRef.getDocument() {
                            if document.exists {
                                let userData = document.data()
                                self.user = User(id: userId, fullname: userData!["fullname"] as? String ?? "", email: userData!["email"] as? String ?? "", Username: userData!["Username"] as? String ?? "", profileImageUrl: userData!["profileImageUrl"] as? String ?? "", bio: userData!["bio"] as? String ?? "")
                                print("User document exists \(self.user)")
                            } else {
                                print("User document does not exist.")
                            }
                        }
                    } catch {
                        print("Error fetching user data: \(error.localizedDescription)")
                    }
                }
                
                db.collection("users").document(userId).collection("posts").getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching user posts: \(error.localizedDescription)")
                        return
                    }
                    
                    self.userPosts = snapshot?.documents.compactMap { document in
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
                    } ?? []
                }
            } else {
                print("No user found with the username \(username).")
            }
        }
    }
}


// You may need to adjust the ProfileHeaderView and ViewerPostView based on your existing implementation.


struct ViewerProfileHeaderView: View {
    
    var user: User
    var postsCount: Int
    
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
                
                VStack(alignment: .center) {
                    Text("1.5M")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 2)
                    Text("Followers")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                
                VStack(alignment: .center) {
                    Text("500")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 2)
                    Text("Following")
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


struct ViewerPostView: View {
    @State private var isPresented: Bool = false
    var post: Post
    
    var body: some View {
        NavigationLink(destination: ViewerInstagramPostView(post: post)) {
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
