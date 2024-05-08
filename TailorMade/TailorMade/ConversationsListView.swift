//ALL CODE BY SHARVAY AJIT
// SwiftUI view for displaying a list of conversations

import SwiftUI
import Firebase
// View model for managing conversations

struct ConversationsListView: View {
    @StateObject private var viewModel = ConversationsListViewModel()
    // State to manage the visibility of the new message view

    @State private var showingNewMessageView = false

    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
                // Navigation link to the detail view for each conversation
                NavigationLink(destination: DM_Page(conversationId: conversation.id, receiverId: conversation.recipientId)) {
                    Text("Conversation with: \(conversation.recipientEmail)")
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Messages")
            // Navigation bar button to trigger showing the new message view

            .navigationBarItems(trailing: Button(action: { showingNewMessageView = true }) {
                Image(systemName: "square.and.pencil")
            })
            // Sheet to present the new message view

            .sheet(isPresented: $showingNewMessageView) {
                NewMessageView()
            }
        }
        // Fetch conversations when the view appears

        .onAppear {
            viewModel.fetchConversations()
        }
    }
}
// View model for managing conversations

class ConversationsListViewModel: ObservableObject {
    // Published property to hold the list of conversations
    @Published var conversations: [ConversationSummary] = []
    // Firestore database reference

    private var db = Firestore.firestore()
    // Function to fetch conversations from Firestore


    func fetchConversations() {
        // Check if the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        // Add a snapshot listener to fetch conversations
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching conversations: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No conversations found")
                    return
                }
                // Iterate through document snapshots
                self?.conversations = documents.compactMap { documentSnapshot in
                    let data = documentSnapshot.data()
                    let id = documentSnapshot.documentID
                    // Extract recipient information
                    if let recipientIds = data["participants"] as? [String],
                       let recipientId = recipientIds.first(where: { $0 != currentUserId }) {
                        // Fetch recipient's user data
                        self?.fetchUserData(userId: recipientId) { userData in
                            if let userData = userData {
                                DispatchQueue.main.async {
                                    // Create conversation summary
                                    let summary = ConversationSummary(id: id, recipientId: recipientId, recipientEmail: userData.email)
                                    // Add conversation summary if not already present

                                    if !(self?.conversations.contains(summary) ?? true) {
                                        self?.conversations.append(summary)
                                    }
                                }
                            }
                        }
                    }

                    return nil // We don't want to add nil to the array
                }
            }
    }
    // Function to fetch user data from Firestore
    private func fetchUserData(userId: String, completion: @escaping (UserData?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil)
                return
            }
            let data = snapshot.data()
            let email = data?["email"] as? String
            let userData = email.map { UserData(email: $0) }
            completion(userData)
        }
    }
}
// Model representing user data
struct UserData {
    let email: String
}
// Model representing a conversation summary
struct ConversationSummary: Identifiable, Equatable {
    let id: String
    var recipientId: String
    var recipientEmail: String
}

// Preview for SwiftUI Canvas
struct ConversationsListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsListView()
    }
}
