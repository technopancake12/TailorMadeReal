// OfferListView.swift
import SwiftUI
import Firebase

struct OfferListView: View {
    var post: Post
    @State private var offers: [Offer] = []
    @State private var isLoading: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        let user = viewModel.currentUser!.id
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                List {
                    ForEach(offers) { offer in
                        OfferRow(offer: offer)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await fetchOffers(userId: user, postId: post.pid)
            }
        }
        .navigationTitle("Offers")
    }
    
    func fetchOffers(userId: String, postId: String) async {
       do {
           let db = Firestore.firestore()
           let offersQuery = try await db.collection("users").document(userId).collection("posts").document(postId).collection("offers").getDocuments()

           offers = try offersQuery.documents.compactMap { document in
               guard
                   let offerAmount = document["offerAmount"] as? Double,
                   let message = document["message"] as? String,
                   let senderUserID = document["senderUserID"] as? String,
                   let id = document.documentID as? String
               else {
                   print("Error decoding offer data: One or more properties missing")
                   return nil
               }

               return Offer(
                   offerAmount: offerAmount,
                   message: message,
                   senderUserID: senderUserID
               )
           }

       } catch {
           print("Error fetching offers: \(error.localizedDescription)")
       }
   }

}

struct OfferRow: View {
    var offer: Offer
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Offer Amount: \(offer.offerAmount)")
            Text("Message: \(offer.message)")
            Text("Sender: \(offer.senderUserID)")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.vertical, 4)
        .overlay(
            NavigationLink(destination: OfferDetailView(offer: offer)) {
                EmptyView()
            }
            .buttonStyle(PlainButtonStyle())
        )
    }
}

struct OfferDetailView: View {
    var offer: Offer
    
    var body: some View {
        VStack {
            Text("Offer Detail")
                .font(.title)
                .padding()
            
            Text("Offer Amount: \(offer.offerAmount)")
                .padding()
            
            Text("Message: \(offer.message)")
                .padding()
            
            Text("Sender: \(offer.senderUserID)")
                .padding()
            
            HStack {
                Button(action: {
                    // Action to accept the offer
                    acceptOffer()
                }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    // Action to reject the offer
                    rejectOffer()
                }) {
                    Text("Reject")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Offer Detail")
    }
    
    private func acceptOffer() {
        // Implement logic to accept the offer
        // You can update the offer status in Firestore or perform any other action
        
        // For example:
        print("Offer accepted")
    }
    
    private func rejectOffer() {
        // Implement logic to reject the offer
        // You can update the offer status in Firestore or perform any other action
        
        // For example:
        print("Offer rejected")
    }
}
