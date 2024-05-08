//import SwiftUI
//

import SwiftUI
//// DM_Page: A SwiftUI view for displaying and sending messages in a direct message conversation.
//struct DM_Page: View {
//    @StateObject private var viewModel: DMViewModel // ViewModel to handle data and logic.
//    @State private var newMessageText = "" // Text field state for the new message input.
//    let receiverId: String // ID of the message receiver.
//
//    // Initializes the view with a conversation ID and receiver ID.
//    init(conversationId: String, receiverId: String) {
//        // Initializing the ViewModel with the conversation and receiver IDs.
//        _viewModel = StateObject(wrappedValue: DMViewModel(conversationId: conversationId, receiverId: receiverId))
//        self.receiverId = receiverId
//    }
//
//    var body: some View {
//        VStack {
//            // List of messages in the conversation.
//            List(viewModel.messages) { message in
//                // Displaying each message content.
//                Text(message.content)
//            }
//
//            // Horizontal stack for the new message input field and send button.
//            HStack {
//                // TextField for typing a new message.
//                TextField("Type a message...", text: $newMessageText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Style for the text field.
//                    .padding()
//
//                // Button to send the message.
//                Button("Send") {
//                    // Check if the conversation already exists; if so, send a message.
//                    if viewModel.isConversationExisting() {
//                        viewModel.sendMessage(to: receiverId, content: newMessageText)
//
//                    } else {
//                        // If it's a new conversation, create a new message thread.
//                        viewModel.sendNewMessage(receiverId: receiverId, content: newMessageText)
//                    }
//                    // Clear the text field after sending the message.
//                    newMessageText = ""
//                }
//                .disabled(newMessageText.isEmpty) // Disable the button if the text field is empty.
//            }
//            .padding()
//        }
//        .onAppear {
//            // Fetch existing messages when the view appears.
//            viewModel.fetchMessages()
//        }
//    }
//}
//struct DM_Page: View {
//    @StateObject private var viewModel: DMViewModel // ViewModel to handle data and logic.
//    @State private var newMessageText = "" // Text field state for the new message input.
//    let receiverId: String // ID of the message receiver.
//
//    init(conversationId: String, receiverId: String) {
//        _viewModel = StateObject(wrappedValue: DMViewModel(conversationId: conversationId, receiverId: receiverId))
//        self.receiverId = receiverId
//    }
//
//    var body: some View {
//        VStack {
//
//            Text(viewModel.receiverName)
//                           .font(.title)
//                           .padding()
//            List(viewModel.messages) { message in
//                HStack {
//                    if message.isCurrentUser {
//                        Spacer() // Pushes the content to the right
//                        Text(message.content)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                    } else {
//                        Text(message.content)
//                            .padding()
//                            .background(Color.gray)
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                        Spacer() // Pushes the content to the left
//                    }
//                }
//            }
//
//            HStack {
//                TextField("Type a message...", text: $newMessageText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//
//                Button("Send") {
//                    if viewModel.isConversationExisting() {
//                        viewModel.sendMessage(to: receiverId, content: newMessageText)
//                    } else {
//                        viewModel.sendNewMessage(receiverId: receiverId, content: newMessageText)
//                    }
//                    newMessageText = ""
//                }
//                .disabled(newMessageText.isEmpty)
//            }
//            .padding()
//        }
//        .onAppear {
//            viewModel.fetchMessages()
//        }
//    }
//}
struct DM_Page: View {
    @StateObject private var viewModel: DMViewModel // ViewModel to handle data and logic.
    @State private var newMessageText = "" // Text field state for the new message input.
    let receiverId: String // ID of the message receiver.

    
    init(conversationId: String, receiverId: String) {
        _viewModel = StateObject(wrappedValue: DMViewModel(conversationId: conversationId, receiverId: receiverId))
        self.receiverId = receiverId
    }
    var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    List(viewModel.messages) { message in
                        HStack {
                            if message.isCurrentUser {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }

                    HStack {
                        TextField("Type a message...", text: $newMessageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Button(action: {
                            if viewModel.isConversationExisting() {
                                viewModel.sendMessage(to: receiverId, content: newMessageText)
                            } else {
                                viewModel.sendNewMessage(receiverId: receiverId, content: newMessageText)
                            }
                            newMessageText = ""
                        }) {
                            Text("Send")
                        }
                        .disabled(newMessageText.isEmpty)
                    }
                    .padding()
                }
                .navigationBarTitle(Text(viewModel.receiverName), displayMode: .large)
                .onAppear {
                    viewModel.fetchMessages()
                }
            }
        }
}
