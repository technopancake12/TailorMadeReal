
import SwiftUI

// SwiftUI view for displaying an individual chat message.
struct DM_MessageView: View {
    let message: ChatMessage // The chat message to be displayed

    var body: some View {
        HStack {
            Text("[\(message.fullname)]:" + "\(message.content)\"")
                .padding()
                .background(message.isCurrentUser ? Color.white : Color.gray.opacity(0.5)) // White background for sent messages, gray for received
                .cornerRadius(10) // Rounded corners for the message bubble
                .padding(message.isCurrentUser ? .leading : .trailing, 60) // Adjust padding for left or right alignment
                // This padding ensures messages are offset from the screen edge.
        }
    }
}

