//ALL CODE IN THIS FILE BY SHARVAY AJIT
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

// ViewModel for managing direct messaging (DM) functionalities in an app.
class DMViewModel: ObservableObject {
    // Published properties to allow the view to update reactively when changes occur.
    @Published var currentUserId: String = ""   // Current user's unique identifier.
    @Published var messages: [ChatMessage] = [] // An array to hold the chat messages.
    @Published var receiverName: String = ""    // Stores the name of the message receiver.

    private var db = Firestore.firestore()       // Firestore database instance.
    private var conversationId: String?          // Optional property to store the current conversation ID.
    private var receiverId: String?              // Optional property to store the receiver's user ID.

    // Initializer that optionally takes a conversation ID and a receiver ID.
    init(conversationId: String? = nil, receiverId: String?) {
        self.conversationId = conversationId
        self.receiverId = receiverId
        if conversationId != nil {
            fetchMessages() // Fetch messages if conversation ID is present.
        }
        fetchReceiverName() // Fetch the name of the receiver based on the receiver ID.
    }

    // Function to fetch the name of the message receiver from Firestore.
    func fetchReceiverName() {
        guard let receiverId = receiverId else { return }
        db.collection("users").document(receiverId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.receiverName = data?["email"] as? String ?? "Unknown"
            } else {
                print("Document does not exist") // Error handling if the document is not found.
            }
        }
    }

    // Function to determine if a conversation exists.
    func isConversationExisting() -> Bool {
        return conversationId != nil
    }

    // Function to fetch messages for the current conversation from Firestore.
    func fetchMessages() {
        guard let conversationId = conversationId else { return }
        
        // Firestore query to fetch messages ordered by timestamp within a specific conversation.
        db.collection("conversations").document(conversationId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                // Mapping Firestore documents to ChatMessage model objects.
                self?.messages = documents.compactMap { document -> ChatMessage? in
                    try? document.data(as: ChatMessage.self)
                }
            }
    }

    // Function to send a message to an existing conversation.
    func sendMessage(to receiverId: String, content: String) {
        guard let senderId = Auth.auth().currentUser?.uid, let conversationId = conversationId else {
            print("User not logged in or conversation ID not set")
            return
        }

        // Message data dictionary prepared for Firestore.
        let messageData: [String: Any] = [
            "fullname": Auth.auth().currentUser?.displayName ?? "Unknown",
            "senderId": senderId,
            "receiverId": receiverId,
            "content": content,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Adding the message document to the Firestore collection.
        db.collection("conversations").document(conversationId).collection("messages")
          .addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message successfully sent to user \(receiverId)")
                // Optionally create a notification for the receiver.
                self.createNotificationForReceiver(receiverId, content: "You have a new message!")
            }
        }
    }

    func sendNewMessage(receiverEmail: String, content: String) {
        guard let senderId = Auth.auth().currentUser?.uid else {
            print("Error: Sender ID (current user ID) is not available.")
            return
        }

        // First, find the receiver's user ID by their email
        db.collection("users").whereField("email", isEqualTo: receiverEmail).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error finding user by email: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No users found with that email")
                return
            }

            let receiverId = documents.first!.documentID

            // Data model for a new conversation.
            let conversationData: [String: Any] = [
                "participants": [senderId, receiverId],
                "lastMessage": content,
                "timestamp": FieldValue.serverTimestamp()
            ]

            // Adding the new conversation document to Firestore.
            let conversationRef = self?.db.collection("conversations").document()
            conversationRef?.setData(conversationData) { error in
                if let error = error {
                    print("Error creating conversation: \(error.localizedDescription)")
                    return
                }

                // If the conversation is successfully created, send the first message.
                self?.sendFirstMessage(to: conversationRef!.documentID, senderId: senderId, receiverId: receiverId, content: content)
            }
        }
    }

    func sendFirstMessage(to conversationId: String, senderId: String, receiverId: String, content: String) {
        let messageData: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "content": content,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Adding the message to the newly created conversation
        db.collection("conversations").document(conversationId).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message successfully sent to user \(receiverId)")
            }
        }
    }



    // Private function to create a notification for the receiving user when a message is sent.
    private func createNotificationForReceiver(_ receiverId: String, content: String) {
        let notificationData: [String: Any] = [
            "content": content,
            "isRead": false,
            "timestamp": FieldValue.serverTimestamp(),
            "type": "Message",
            "userID": receiverId
        ]

        // Creating a notification document in Firestore.
        db.collection("notifications").addDocument(data: notificationData) { error in
            if let error = error {
                print("Error creating notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully created for user \(receiverId)")
            }
        }
    }
}

