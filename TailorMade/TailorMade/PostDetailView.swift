import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift

struct InstagramPostView: View {
    var post: Post
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var likeCount: Int = 0
    @State private var commentCount: Int = 0
    @State private var commentText: String = ""
    @State private var postUser: User?
    @State private var comments: [Comment] = []
    @State private var isCommentFieldVisible: Bool = false
    @State private var showAllComments: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User Info: Profile Picture and Username
            if let postUser = postUser {
                HStack(spacing: 8) {
                    let profilePictureURL = postUser.profileImageUrl
                    WebImage(url: URL(string: profilePictureURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    let username = postUser.Username
                    Text(username)
                        .font(.headline)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            
            // Post Image
            WebImage(url: URL(string: post.imageUrl))
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .clipped()
            
            HStack(spacing: 16) {
                // Like Button
                Button(action: {
                    toggleLike()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isLiked ? Color.red : Color.black)
                }
                
                // Comment Button
                Button(action: {
                    // Show/hide the comment field
                    isCommentFieldVisible.toggle()
                }) {
                    Image(systemName: "message.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.black)
                }
                
                Spacer()
                
                // Save Button
                Button(action: {
                    toggleBookmark()
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.black)
                }
            }
            .padding(.horizontal, 16)
            
            // Like and Comment Count
            Text("\(likeCount) likes")
                .font(.caption)
                .padding(.horizontal, 16)
            
            Button(action: {
                // Toggle showAllComments flag
                showAllComments.toggle()
            }) {
                Text(showAllComments ? "Hide comments" : "View all \(commentCount) comments")
                    .font(.caption)
                    .padding(.horizontal, 16)
            }
            
            // Comments
            if showAllComments { // Show comments only if showAllComments is true
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(comments) { comment in
                        Text("\(comment.username): \(comment.text)")
                            .font(.body)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Comment Input Field
            if isCommentFieldVisible {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .onSubmit {
                        // Add your comment submission logic here
                        addComment()
                        isCommentFieldVisible = false
                    }
            }
            NavigationLink(destination: OfferListView(post: post)) {
                Text("Offer")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 8)
        .onAppear {
            // Fetch user info from Firestore
            fetchPostUser()
            fetchComments()
            fetchLikeStatus()
            fetchBookmarkStatus()
        }
    }
    
    private func fetchPostUser() {
        let userId = post.userId
        let postId = post.pid
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist.")
                return
            }
            
            if let userData = document.data() {
                postUser = User(id: userId, fullname: userData["fullname"] as? String ?? "", email: userData["email"] as? String ?? "", Username: userData["Username"] as? String ?? "", profileImageUrl: userData["profileImageUrl"] as? String ?? "", bio: userData["bio"] as? String ?? "")
                print("DEBUG: Post user is \(postUser)")
            }
        }
    }
    
    // Function to toggle the like state
    private func toggleLike() {
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        updateLikesInFirestore()
    }
    
    // Function to toggle the bookmark state
    private func toggleBookmark() {
        isBookmarked.toggle()
        updateBookmarkInFirestore()
    }
    
    // Function to update likes in Firestore
    private func updateLikesInFirestore() {
        let userId = viewModel.currentUser?.id ?? ""
        let postId = post.pid
        let db = Firestore.firestore()
        
        // Update like status locally
        likeCount += isLiked ? 1 : -1
        
        if isLiked {
            // Add user's ID to the likes collection
            db.collection("users").document(userId).collection("posts").document(postId).collection("likes").document(userId).setData(["liked": true]) { error in
                if let error = error {
                    print("Error updating like status: \(error.localizedDescription)")
                }
            }
        } else {
            // Remove user's ID from the likes collection
            db.collection("users").document(userId).collection("posts").document(postId).collection("likes").document(userId).delete { error in
                if let error = error {
                    print("Error updating like status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Function to update bookmark status in Firestore
    private func updateBookmarkInFirestore() {
        guard let userId = viewModel.currentUser?.id else {
            print("User ID not available")
            return
        }

        let postId = post.pid // Use post's pid property
        let db = Firestore.firestore()

        if isBookmarked {
            // Add post data to user's saved posts collection
            let postData: [String: Any] = [
                "postId": postId,
                "imageUrl": post.imageUrl,
                "userId": post.userId,
                "likes": post.likes,
                "commentCount": post.commentCount
            ]

            db.collection("users").document(userId).collection("saved_posts").document(postId).setData(postData, merge: true) { error in
                if let error = error {
                    print("Error saving post: \(error.localizedDescription)")
                } else {
                    print("Post bookmarked successfully")
                }
            }
        } else {
            // Remove post from user's saved posts collection
            db.collection("users").document(userId).collection("saved_posts").document(postId).delete { error in
                if let error = error {
                    print("Error removing post: \(error.localizedDescription)")
                } else {
                    print("Post removed from bookmarks successfully")
                }
            }
        }
    }




    
    // Function to check if the current user has bookmarked the post
    private func fetchBookmarkStatus() {
        let userId = viewModel.currentUser?.id ?? ""
        let postId = post.pid
        let db = Firestore.firestore()
        
        // Fetch bookmark status from Firestore
        db.collection("users").document(userId).collection("saved_posts").document(postId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching bookmark status: \(error.localizedDescription)")
                return
            }
            
            isBookmarked = snapshot?.exists ?? false
        }
    }
    // Function to check if the current user has liked the post
    private func fetchLikeStatus() {
        let userId = viewModel.currentUser?.id ?? ""
        let postId = post.pid
        let db = Firestore.firestore()
        
        // Fetch like status from Firestore
        db.collection("users").document(userId).collection("posts").document(postId).collection("likes").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching like status: \(error.localizedDescription)")
                return
            }
            
            if let _ = snapshot?.data() {
                // User has liked the post
                isLiked = true
            } else {
                // User has not liked the post
                isLiked = false
            }
        }
        
        // Fetch like count from Firestore
        db.collection("users").document(userId).collection("posts").document(postId).collection("likes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching like count: \(error.localizedDescription)")
                return
            }
            
            likeCount = snapshot?.documents.count ?? 0
        }
    }
    
    // Function to add a new comment
    private func addComment(){
        guard !commentText.isEmpty, let userId = Auth.auth().currentUser?.uid else {
            // Handle case where comment text is empty or user ID is unavailable
            return
        }
        let user = viewModel.currentUser
        let postId = post.pid
        let db = Firestore.firestore()

        // Reference to the comments collection under the post document
        let commentsRef = db.collection("users").document(userId).collection("posts").document(postId).collection("comments").document()
        
        
        // Set the comment data
        let newComment: [String: Any] = [
            "userId": userId,
            "text": commentText,
            "username": user!.Username
        ]

        // Save the comment data to Firestore
        commentsRef.setData(newComment) { error in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            } else {
                // Comment added successfully
                print(commentText)
                commentText = ""
            }
        }
    }

    // Function to fetch comments from Firestore
    private func fetchComments() {
        let userId = post.userId
        let postId = post.pid
        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("posts").document(postId).collection("comments").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching comments: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            comments = snapshot.documents.compactMap { document in
                let commentId = document.documentID
                let userId = document["userId"] as? String ?? ""
                let text = document["text"] as? String ?? ""
                let username = document["username"] as? String ?? ""

                return Comment(commentId: commentId, userId: userId, text: text, username: username)
            }

            commentCount = comments.count
        }
    }
}
