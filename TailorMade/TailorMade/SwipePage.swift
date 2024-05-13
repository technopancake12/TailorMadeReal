//import SwiftUI
import Firebase
import SDWebImageSwiftUI

import SwiftUI

struct SwipePage: View {
    @State private var userPosts: [String] = []
    @State private var currentIndex: Int = 0
    @State private var selectedCategory: String? = nil
    @State private var showCategoryMenu = false

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Category: ")
                    Button(action: {
                        withAnimation {
                            showCategoryMenu.toggle()
                        }
                    }) {
                        //Added dropdown to choose categories - Sharvay Ajit
                        Text(selectedCategory ?? "Select Category")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
        
                    if showCategoryMenu {
                        Spacer()
                        VStack {
                            //Menu Options - Sharvay Ajit
                            Button(action: {
                                selectedCategory = "All"
                                fetchUserPosts()
                                showCategoryMenu.toggle()
                            }) {
                                Text("All")
                                    .padding(.vertical, 5)
                            }
                            Divider()
                            Button(action: {
                                selectedCategory = "T-Shirts"
                                fetchUserPosts()
                                showCategoryMenu.toggle()
                            }) {
                                Text("T-Shirts")
                                    .padding(.vertical, 5)
                            }
                            Divider()
                            Button(action: {
                                selectedCategory = "Shoes"
                                fetchUserPosts()
                                showCategoryMenu.toggle()
                            }) {
                                Text("Shoes")
                                    .padding(.vertical, 5)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(5)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }

                if userPosts.isEmpty { //Default text if there are no posts to scroll through -Sharvay Ajit
                    Text("No more photos for now")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(userPosts.indices, id: \.self) { index in
                            WebImage(url: URL(string: userPosts[index]))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 300, maxHeight: 300)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .onTapGesture {
                showCategoryMenu = false
            }

            SwipeOverlayView {
                if currentIndex == userPosts.count - 1 {

                }
            }
        }
        .gesture(DragGesture()
            .onChanged { value in
                if value.translation.width < 0 {
                    currentIndex = min(currentIndex + 1, userPosts.count - 1)
                } else if value.translation.width > 0 {
                    currentIndex = max(currentIndex - 1, 0)
                }
            }
        )
        .onAppear {
            // Initially fetch user posts from Firestore
            fetchUserPosts()
        }
    }

    private func fetchUserPosts() {
        // Fetch user posts based on the selected category
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        var query: Query = db.collection("users").document(userId).collection("posts")

        if let selectedCategory = selectedCategory, selectedCategory != "All" {
            query = query.whereField("category", isEqualTo: selectedCategory)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user posts: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            self.userPosts = documents.compactMap { document in
                if let imageUrl = document["imageUrl"] as? String {
                    return imageUrl
                }
                return nil
            }
        }
    }
}






//View for category selection - Sharvay Ajit
struct CategorySelectionView: View {
    @Binding var isCategorySelected: Bool
    @State private var selectedCategory: String?

    var body: some View {
        VStack {
            Text("Select a category") //Category Selection
                .font(.title)
                .padding()

            Button(action: {
                // Set selected category and dismiss the sheet
                selectedCategory = "T-Shirts" // You can set the selected category here
                isCategorySelected = false
            }) {
                Text("T-Shirts")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: {
                // Set selected category and dismiss the sheet
                selectedCategory = "Shoes" // You can set the selected category here
                isCategorySelected = false
            }) {
                Text("Shoes")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
    }
}



struct SwipeOverlayView<Content: View>: View {
    let action: () -> Content

    init(@ViewBuilder action: @escaping () -> Content) {
        self.action = action
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "x.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .padding()
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                    .padding()
                action()
                Spacer()
            }
        }
    }
}

//ALL CODE BELOW THIS LINE BY SHARVAY AJIT
import Foundation

// define a user class with preference attributes and total likes count
class User_Pref {
    var likesCurrentPost: Bool
    var streetPref: Int = 0
    var casualPref: Int = 0
    var formalPref: Int = 0
    var totalLikes: Int = 0

    // initialize a user with their current post preference
    init(likesCurrentPost: Bool) {
        self.likesCurrentPost = likesCurrentPost
    }
}

// define an enumeration for post styles
enum PostStyle {
    case street, casual, formal
}

// define a post class with a style attribute
class Post_Pref {
    var style: PostStyle

    // initialize a post with a specific style
    init(style: PostStyle) {
        self.style = style
    }
}

// function to update user preferences based on their interaction with a post
func swipeScore(userPref: User_Pref, postPref: Post_Pref) -> User_Pref {
    // check if the user likes the current post
    if userPref.likesCurrentPost {
        // increment the preference count based on the post's style
        switch postPref.style {
        case .street:
            userPref.streetPref += 1
        case .casual:
            userPref.casualPref += 1
        case .formal:
            userPref.formalPref += 1
        }
        userPref.totalLikes += 1
    } else {
        userPref.totalLikes += 1
    }
    return userPref
}

// function to determine the next post to show based on user preferences
func swipeAlgo(userPref: User_Pref, posts: [Post_Pref]) -> Post_Pref? {
    // calculate the preference percentages
    let streetPercent = Double(userPref.streetPref) / Double(userPref.totalLikes)
    let casualPercent = Double(userPref.casualPref) / Double(userPref.totalLikes)
    let formalPercent = Double(userPref.formalPref) / Double(userPref.totalLikes)
    let swipeRoll = Double.random(in: 0...1)

    var nextPost: Post_Pref?

    // determine which post to show next based on the random swipe roll and preference percentages
    if swipeRoll < streetPercent {
        nextPost = posts.first { $0.style == .street }
    } else if swipeRoll < streetPercent + casualPercent {
        nextPost = posts.first { $0.style == .casual }
    } else if swipeRoll < streetPercent + casualPercent + formalPercent {
        nextPost = posts.first { $0.style == .formal }
    }

    return nextPost
}
