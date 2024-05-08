//ALL CODE IN THIS FILE BY SHARVAY AJIT
import FirebaseFirestoreSwift
import Firebase

// Defines a data model for notifications that is identifiable (for SwiftUI Lists) and encodable/decodable (for Firestore).
struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    var content: String
    var isRead: Bool
    var timestamp: Date
    var type: String
    var userID: String

    // Specifies how the data fields map to Firestore keys when encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isRead = "isRead"  // Maps the 'isRead' property to 'isRead' in Firestore.
        case timestamp
        case type
        case userID = "userID"  // Ensures the 'userID' property maps to 'userID' in Firestore.
    }
}



// ViewModel to manage notification data within the app.
class NotificationsViewModel: ObservableObject {
    @Published var notifications = [NotificationModel]()  // The list of notifications to be displayed.

    private var db = Firestore.firestore()  // Access to the Firestore database.

    // Initializes and fetches notifications on creation.
    init() {
        fetchNotifications()
    }

    // Fetches notifications from Firestore specific to the logged-in user and orders them by timestamp.
    func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")  // Checks if the user is logged in.
            return
        }

        db.collection("notifications")
            .whereField("userID", isEqualTo: userId)  // Filters notifications by user ID.
            .order(by: "timestamp", descending: true)  // Orders notifications by timestamp in descending order.
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")  // Error handling.
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")  // Check for non-empty query results.
                    return
                }
                // Maps documents to NotificationModel objects.
                self?.notifications = documents.compactMap { document in
                    try? document.data(as: NotificationModel.self)
                }
            }
    }
}

import SwiftUI

// SwiftUI view for displaying a list of notifications.
struct NotificationsView: View {
    @ObservedObject var viewModel = NotificationsViewModel()  // Observes changes in the ViewModel.

    var body: some View {
        NavigationView {
            List(viewModel.notifications) { notification in
                VStack(alignment: .leading) {
                    Text(notification.content)  // Display the content of the notification.
                    Text(notification.timestamp.formatted(date: .abbreviated, time: .shortened))  // Display formatted timestamp.
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Notifications")  // Sets the title of the navigation bar.
        }
        .onAppear {
            viewModel.fetchNotifications()  // Refresh notifications when the view appears.
        }
    }
}
//
//struct NotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationsView()
//    }
//}
