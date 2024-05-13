import SwiftUI
import Firebase
struct Offer: Identifiable, Decodable { // Conforming to Identifiable and Decodable
    var id = UUID() // Adding a unique identifier
    let offerAmount: Double
    let message: String
    let senderUserID: String
    // Add any other properties you need for the offer
    
    // Initializer if needed
    init(offerAmount: Double, message: String, senderUserID: String) {
        self.offerAmount = offerAmount
        self.message = message
        self.senderUserID = senderUserID
    }
}

struct OfferingView: View {
    @State private var offerAmount: String = ""
    @State private var message: String = ""
    var post: Post
    
    var body: some View {
        VStack {
            Text("Make an Offer")
                .font(.title)
                .padding()
            
            TextField("Offer Amount", text: $offerAmount)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            TextField("Message", text: $message)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                // Implement your offer submission logic here
                submitOffer()
            }) {
                NavigationLink(destination: PaymentPortal()){
                    Text("Send Offer")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }}
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Offer Money", displayMode: .inline)
    }
    
    private func submitOffer() {
        guard let amount = Double(offerAmount),
              let currentUserID = Auth.auth().currentUser?.uid else {
            // Handle invalid amount or user ID
            return
        }
        
        let db = Firestore.firestore()
        let offerData: [String: Any] = [
            "senderUserID": currentUserID,
            "receiverUserID": post.userId, // Assuming post.userId is the seller's user ID
            "offerAmount": amount,
            "message": message
        ]
        
        // Reference to the offers collection under the post document
        let postRef = db.collection("users").document(post.userId).collection("posts").document(post.pid)
        let offersRef = postRef.collection("offers")
        
        // Add the offer data to Firestore
        offersRef.addDocument(data: offerData) { error in
            if let error = error {
                print("Error adding offer: \(error.localizedDescription)")
            } else {
                print("Offer added successfully")
                // Optionally, you can show an alert or navigate to another view upon successful offer submission
            }
        }
    }
}
