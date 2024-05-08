import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct CollectionsPage: View {
    @State private var savedPosts: [Post] = [] // Define a state variable to store an array of Post objects, initialized as empty
    @State private var selectedPost: Post?
    @State private var selectedCollection: DocumentWrapper?
    @State private var savedCollections: [DocumentWrapper] = [] // Define a state variable to store fetched collections
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = "Posts" // Define a state variable for the selected tab
    @State private var showCreateCollection = false // Flag to control visibility of "Create new Collection" button
    @State private var newCollectionName = "" // State variable to store the new collection name
    @State private var isAddingCollection = false // State variable to control the sheet presentation
    @State private var selectedPosts: [Post] = []
    @State private var showPosts = false
    @State private var postsInCollection: [Post] = []
    
    // Define a unique notification name for data refresh
    static let refreshNotification = Notification.Name("RefreshCollectionsPage")
    
    private func toggleSelection(for index: Int) {
        if selectedPosts.contains(savedPosts[index]) {
            selectedPosts.removeAll { $0 == savedPosts[index] }
        } else {
            selectedPosts.append(savedPosts[index])
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                HStack {
                    Spacer()
                    TabButton(title: "Posts", selectedTab: $selectedTab)
                    Spacer()
                    TabButton(title: "Collections", selectedTab: $selectedTab)
                    Spacer()
                }
                .font(.title)
                .padding(.vertical, 10)

                Divider()

                if selectedTab == "Posts" {
                    if savedPosts.isEmpty {
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                ForEach(savedPosts) { post in
                                    WebImage(url: URL(string: post.imageUrl))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            selectedPost = post
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                } else if selectedTab == "Collections" {
                    Button(action: {
                        isAddingCollection.toggle()
                    }) {
                        Image(systemName: "plus")
                        Text("Create new Collection")
                    }
                    .padding()
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.slide)

                    if savedCollections.isEmpty {
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                ForEach(savedCollections, id: \.id) { collection in
                                    VStack {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                selectedCollection = collection
                                            }
                                        Text(collection.document.documentID)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Collections")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EmptyView())
            .onAppear {
                fetchSavedPosts()
                fetchSavedCollections { documents in
                    savedCollections = documents.map { DocumentWrapper(id: $0.documentID, document: $0) }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Self.refreshNotification)) { _ in
                // Refresh data when the notification is received
                fetchSavedPosts()
                fetchSavedCollections { documents in
                    savedCollections = documents.map { DocumentWrapper(id: $0.documentID, document: $0) }
                }
            }
            .sheet(item: $selectedPost) { post in
                InstagramPostView(post: post)
                    .onDisappear {
                        NotificationCenter.default.post(name: CollectionsPage.refreshNotification, object: nil)
                    }
            }

            .sheet(item: $selectedCollection) { collection in
                VStack(spacing: 10){
                    Text(collection.document.documentID)
                        .font(.title)
                        .padding(.top, 25)
                        

                    // Button to toggle display of posts
                    if !showPosts {
                        Button("Add posts") {
                            showPosts.toggle() // Toggle the state to show/hide posts
                        }
                        .padding()
                        .foregroundColor(.blue)
                        
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                ForEach(postsInCollection) { post in
                                    WebImage(url: URL(string: post.imageUrl))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            selectedPost = post
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Conditionally display posts based on showPosts state
                    if showPosts {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(savedPosts.indices, id: \.self) { index in
                                    let post = savedPosts[index]
                                    HStack {
                                        Image(systemName: selectedPosts.contains(post) ? "checkmark.square.fill" : "square")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .onTapGesture {
                                                toggleSelection(for: index) // Use the index for toggleSelection
                                            }
                                        // Display the image using WebImage
                                        WebImage(url: URL(string: post.imageUrl))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                    }
                                    .padding()
                                }
                            }
                            .padding()
                        }

                        // Button to add selected posts
                        HStack {
                            Button("Cancel") {
                                showPosts = false // Set showPosts to false when Cancel button is clicked
                            }
                            .padding()
                            .foregroundColor(.red)

                            Spacer() // Add spacer to push Cancel button to the right

                            Button("Add selected posts") {
                                // Add selected posts to the collection
                                addSelectedPostsToCollection(collection: collection)
                                showPosts = false // Set showPosts to false after adding selected posts
                            }
                            .padding()
                            .foregroundColor(.blue) // You can change the color as desired
                        }
                        .padding(.horizontal)
                    }

                }
                .onDisappear {
                    showPosts = false // Set showPosts to false when the sheet disappears
                }
                .onAppear {
                    fetchPostsInCollection(collection: collection) // Fetch posts for the selected collection
                }
            }


            .sheet(isPresented: $isAddingCollection, onDismiss: {
                newCollectionName = ""
            }, content: {
                VStack {
                    TextField("Enter collection name", text: $newCollectionName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Create") {
                        checkSavedCollections(collectionName: newCollectionName) { exists in
                            if exists {
                                print("Collection already exists")
                            } else {
                                createNewCollection()
                            }
                            isAddingCollection = false
                        }
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
                .padding()
                .onAppear {
                    newCollectionName = ""
                }
            })
        }
    }
    
    private func fetchPostsInCollection(collection: DocumentWrapper) {
        guard let userId = viewModel.currentUser?.id else {
            return
        }

        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userId).collection("saved_collections").document(collection.id)

        collectionRef.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts in collection: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in collection")
                return
            }

            postsInCollection = documents.compactMap { document in
                guard
                    let imageUrl = document["imageUrl"] as? String,
                    let postId = document["postId"] as? String,
                    let userId = document["userId"] as? String,
                    let likes = document["likes"] as? Int,
                    let commentCount = document["commentCount"] as? Int
                else {
                    print("Missing required fields in document: \(document.documentID)")
                    return nil // Skip this document
                }

                return Post(pid: postId, imageUrl: imageUrl, userId: userId, likes: likes, commentCount: commentCount)
            }
            print("Fetched \(postsInCollection.count) posts in collection")
        }
    }



    
    
    // Function to add selected posts to the collection
    private func addSelectedPostsToCollection(collection: DocumentWrapper) {
        guard let userId = viewModel.currentUser?.id else {
            return
        }

        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userId).collection("saved_collections").document(collection.id)

        for post in selectedPosts {
            let postRef = collectionRef.collection("posts").document(post.pid)
            postRef.setData([
                "imageUrl": post.imageUrl,
                "userId": post.userId,
                "likes": post.likes,
                "commentCount": post.commentCount,
                "postId":post.pid
            ]) { error in
                if let error = error {
                    print("Error adding post to collection: \(error.localizedDescription)")
                } else {
                    print("Post added to collection successfully")
                }
            }
        }

        // Clear selected posts after adding
        selectedPosts = []
    }

    // Function to fetch saved posts from Firestore
    private func fetchSavedPosts() {
        guard let userId = viewModel.currentUser?.id else {
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("saved_posts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching saved posts: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            savedPosts = documents.compactMap { document in
                // Check if the required fields exist in the Firestore document
                guard
                    let imageUrl = document["imageUrl"] as? String,
                    let postId = document["postId"] as? String,
                    let userId = document["userId"] as? String,
                    let likes = document["likes"] as? Int,
                    let commentCount = document["commentCount"] as? Int
                else {
                    // Print a warning and return nil if any required field is missing
                    print("Missing required fields in document: \(document.documentID)")
                    return nil
                }

                // Create a Post object using the retrieved data
                return Post(pid: postId, imageUrl: imageUrl, userId: userId, likes: likes, commentCount: commentCount)
            }
            print("Fetched \(savedPosts.count) saved posts")
        }
    }

    private func addPostsToCollection(collection: DocumentWrapper) {
        guard let userId = viewModel.currentUser?.id else {
            return
        }

        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userId).collection("saved_collections").document(collection.id)

        // Assuming 'savedPosts' contains the posts to add to the collection
        for post in savedPosts {
            let postRef = collectionRef.collection("posts").document(post.pid)
            postRef.setData([
                "imageUrl": post.imageUrl,
                "userId": post.userId,
                "likes": post.likes,
                "commentCount": post.commentCount
            ]) { error in
                if let error = error {
                    print("Error adding post to collection: \(error.localizedDescription)")
                } else {
                    print("Post added to collection successfully")
                }
            }
        }
    }

    private func checkSavedCollections(collectionName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = viewModel.currentUser?.id else {
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("saved_collections").document(collectionName).getDocument { document, error in
            if let error = error {
                print("Error checking saved collections: \(error.localizedDescription)")
                completion(false) // Indicate that an error occurred
                return
            }

            let exists = document?.exists ?? false
            completion(exists)
        }
    }

    private func fetchSavedCollections(completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        guard let userId = viewModel.currentUser?.id else {
            completion([])
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("saved_collections").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching saved collections: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion([])
                return
            }

            let documents = snapshot.documents
            completion(documents)
        }
    }

    // Function to create a new collection with the provided name
    private func createNewCollection() {
        guard let userId = viewModel.currentUser?.id, !newCollectionName.isEmpty else {
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("saved_collections").document(newCollectionName).setData([:]) { error in
            if let error = error {
                print("Error creating new collection: \(error.localizedDescription)")
                return
            }
            print("New collection created successfully")
            // Fetch collections again after creation
            NotificationCenter.default.post(name: CollectionsPage.refreshNotification, object: nil)
        }
    }
}

// TabButton view for handling tab selection
struct TabButton: View {
    var title: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            selectedTab = title
        }) {
            Text(title)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(selectedTab == title ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(Capsule())
        }
    }
}

// Preview provider for CollectionsPage
struct CollectionsPage_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsPage()
    }
}

// Identifiable wrapper for QueryDocumentSnapshot
struct DocumentWrapper: Identifiable {
    var id: String
    var document: QueryDocumentSnapshot
}
