// A SwiftUI view for composing and sending new messages.
import SwiftUI
struct NewMessageView: View {
    @Environment(\.presentationMode) var presentationMode // Used to dismiss the view
    @State private var recipientId = "" // State variable for storing recipient ID
    @State private var messageContent = "" // State variable for storing message content

    var body: some View {
        // Enclosing the content within a NavigationView
        NavigationView {
            VStack {
                // TextField for entering the recipient's ID
                TextField("Recipient Email", text: $recipientId)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Adding border style
                    .padding() // Adding padding around the text field

                                Button("Create Conversation") { // Button for creating new conversation
                                let viewModel = DMViewModel(receiverId: recipientId)
                                    viewModel.sendNewMessage(receiverEmail: recipientId, content: messageContent)

                                    presentationMode.wrappedValue.dismiss()
                                }
                                .disabled(recipientId.isEmpty)
                            }
            // Setting the title for the navigation bar
            .navigationBarTitle("New Message", displayMode: .inline)
            // Adding a cancel button to dismiss the view
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
