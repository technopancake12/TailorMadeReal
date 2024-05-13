//
//  ExplorePageViewModel.swift
//  Tailor Made
//
//  Created by Hoang Le on 2/4/24.
//


import SwiftUI
import Firebase
import SDWebImageSwiftUI

class ExplorePageViewModel: ObservableObject {
    // keep track of all the images we got
    @Published var images = [ImageModel]()
    @Published var storyImages = [StoryImageModel]()
    @Published var currentPage = 1
    // check if there are more images
    @Published var hasMorePages = true
    @Published var searchedUserID: String?
    
    // Firestore reference
    let db = Firestore.firestore()
    
    // keep track of skipped users
    var skippedUsers: Set<String> = []
    
    // keep track of last user processed to avoid consecutive posts from the same user
    var lastProcessedUserID: String?
    
    // Autocomplete suggestions
    @Published var autocompleteSuggestions = [String]()
    
    // grab posts for each user
    func populateData(page: Int, numberOfUsers: Int = 25) {
        var usersQuery = db.collection("users").limit(to: numberOfUsers)
        
        // fetch users' data based on the query
        usersQuery.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting users: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No users found")
                return
            }
            
            // loop through users' data
            for document in documents {
                let userID = document.documentID
                
                // Skip users who have already been processed
                if self.skippedUsers.contains(userID) {
                    continue
                }
                
                let postsRef = self.db.collection("users").document(userID).collection("posts")
                
                // Fetch posts for the user
                postsRef.getDocuments { postsSnapshot, postsError in
                    if let postsError = postsError {
                        print("Error fetching posts for user \(userID): \(postsError)")
                        return
                    }
                    
                    guard let postsDocuments = postsSnapshot?.documents else {
                        print("No posts found for user \(userID)")
                        return
                    }
                
                    
                    // Print the "imageUrl" for each document in "posts" for the user
                    for postDocument in postsDocuments {
                        if let imageUrl = postDocument.data()["imageUrl"] as? String,
                           let pid = postDocument.documentID as? String,
                           let userId = postDocument.data()["userId"] as? String,
                           let likes = postDocument.data()["likes"] as? Int,
                           let commentCount = postDocument.data()["commentCount"] as? Int {
                           // print("Found \(userID) posts: \(pid)")
                            
                            // Add imageUrl to images list
                            DispatchQueue.main.async {
                                self.images.append(ImageModel(url: URL(string: imageUrl)!, pid: pid, userId: userId, likes: likes, commentCount: commentCount))
                            }
                        }
                    }
                }
            }
        }
    }

    func populateStories(page: Int, numberOfUsers: Int = 25) {
        var usersQuery = db.collection("users").limit(to: numberOfUsers)
        
        // fetch users' data based on the query
        usersQuery.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting users: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No users found")
                return
            }
            
            // loop through users' data
            for document in documents {
                let userID = document.documentID
                
                // Skip users who have already been processed
                if self.skippedUsers.contains(userID) {
                    continue
                }
                
                let storiesRef = self.db.collection("users").document(userID).collection("stories")
                
                // Fetch posts for the user
                storiesRef.getDocuments { storiesSnapshot, storiesError in
                    if let storiesError = storiesError {
                        print("Error fetching stories for user \(userID): \(storiesError)")
                        return
                    }
                    
                    guard let storiesDocuments = storiesSnapshot?.documents else {
                        print("No stories found for user \(userID)")
                        return
                    }
                
                    
                    // Print the "imageUrl" for each document in "posts" for the user
                    for storyDocument in storiesDocuments {
                        if let imageUrl = storyDocument.data()["imageUrl"] as? String,
                           let pid = storyDocument.documentID as? String,
                           let userId = storyDocument.data()["userId"] as? String{
                           // print("Found \(userID) posts: \(pid)")
                            
                            // Add imageUrl to images list
                            DispatchQueue.main.async {
                                self.storyImages.append(StoryImageModel(url: URL(string: imageUrl)!, pid: pid, userId: userId ))
                            }
                        }
                    }
                }
            }
        }
    }

    
    
    func searchUserByUsername(username: String) {
        let usersRef = db.collection("users")
        
        // Query Firestore for the user with the given username
        usersRef.whereField("Username", isEqualTo: username).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error searching for user: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No user found with username: \(username)")
                return
            }
            
            // Clear previous suggestions
            self.autocompleteSuggestions.removeAll()
            
            // If the user is found, pass the user's ID to the completion handler
            if let document = documents.first {
                let userID = document.documentID
                self.searchedUserID = userID
                print("User found with username: \(username)")
            } else {
                print("No user found with username: \(username)")
                // Fetch autocomplete suggestions if no user found
                self.fetchAutocompleteSuggestions(for: username)
            }
        }
    }
    
    private func fetchAutocompleteSuggestions(for keyword: String) {
        let usersRef = db.collection("users")
        
        // Query Firestore for usernames similar to the given keyword
        usersRef.whereField("Username", isGreaterThanOrEqualTo: keyword)
            .limit(to: 5)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching autocomplete suggestions: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No autocomplete suggestions found")
                    return
                }
                
                // Add usernames to autocomplete suggestions
                self.autocompleteSuggestions = documents.compactMap { document in
                    let username = document["Username"] as? String ?? ""
                    return username
                }
            }
    }
    
    // this struct holds info about each image
    struct ImageModel: Identifiable, Hashable {
        let id = UUID() // give each image a unique ID
        let url: URL
        let pid: String
        let userId: String
        let likes: Int
        let commentCount: Int

        // Add this initializer
        init(url: URL, pid: String, userId: String, likes: Int, commentCount: Int) {
            self.url = url
            self.pid = pid
            self.userId = userId
            self.likes = likes
            self.commentCount = commentCount
        }
    }
    
    struct StoryImageModel: Identifiable, Hashable {
        let id = UUID() // give each image a unique ID
        let url: URL
        let pid: String
        let userId: String

        // Add this initializer
        init(url: URL, pid: String, userId: String) {
            self.url = url
            self.pid = pid
            self.userId = userId
        }
    }
}
