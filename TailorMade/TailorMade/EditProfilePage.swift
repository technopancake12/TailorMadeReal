//
//  EditProfilePage.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

struct EditProfilePage: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var fullname = ""
    @State private var Username = ""
    @State private var bio = ""
    @State private var website = ""
    @State private var email = ""
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var profileImageUrl: URL?
    
    @State private var isNavigationActive = false
    
    
    var body: some View {
        
        let userId = Auth.auth().currentUser?.uid
        
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 150, alignment: .center)
                            .clipShape(Circle())
                            
                    } else {
                        Image("download")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 150, alignment: .center)
                            .clipShape(Circle())
                    }
                    
                    Button("Select Photo") {
                        isImagePickerPresented.toggle()
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $selectedImage)
                    }
                }
                
                Section(header: Text("User Info")) {
                    TextField("Full name", text: $fullname)
                    TextField("Username", text: $Username)
                    TextField("Bio", text: $bio)
                }
                
                Section {
                    Button(action: {
                        uploadProfilePicture()
                        saveChanges()
                        deletePreviousProfileImage(userId: userId!)
                        isNavigationActive = true
                    }) {
                        Text("Save Changes")
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    NavigationLink(destination: ProfilePage(), isActive: $isNavigationActive) {
                        EmptyView()
                    }.hidden()
                    
                    NavigationLink(){
                        SettingsPage()
                    } label: {
                        Text("Back")
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
        }.navigationBarHidden(true)
    }
    func saveChanges() {
        // Ensure that the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Check if any required field is empty

        // Create a dictionary with the updated user information
        var updatedUserInfo: [String: Any] = [:]
        
        // Add the profile image URL if available
        if let profileImageUrl = profileImageUrl {
            
            updatedUserInfo["profileImageUrl"] = profileImageUrl.absoluteString
        }

        // Add the full name and username
        if !fullname.isEmpty {
            updatedUserInfo["fullname"] = fullname
            print(fullname)
        }
        
        if !Username.isEmpty {
            updatedUserInfo["Username"] = Username
            print(Username)
        }
        
        if !bio.isEmpty {
            updatedUserInfo["bio"] = bio
            print(bio)
        }
        // Add other fields (e.g., bio, website, email) as needed

        // Update the user information in Firestore
        do {
            let db = Firestore.firestore()

            db.collection("users").document(userId).updateData(updatedUserInfo) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
        } catch {
            print("Failed to save with error \(error.localizedDescription)")
        }
    }
    
    
    func uploadProfilePicture() {
           guard let selectedImage = selectedImage else {
               // Handle case where no image is selected
               return
           }

           // Upload to Firebase Storage
           let storage = Storage.storage()
           let storageRef = storage.reference()
           let profileImageRef = storageRef.child("profile_images/\(UUID().uuidString).jpg")

           if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
               let metadata = StorageMetadata()
               metadata.contentType = "image/jpeg"

               profileImageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                   guard let _ = metadata else {
                       // Handle error
                       return
                   }

                   // Get the download URL for the image
                   profileImageRef.downloadURL { (url, error) in
                       guard let downloadURL = url else {
                           // Handle error
                           return
                       }

                       // Store the download URL in Firestore or use it as needed
                       saveProfileImageUrlToFirestore(url: downloadURL)
                   }
               }
           }
       }
    
    func deletePreviousProfileImage(userId: String) {
        let db = Firestore.firestore()
        
        // Fetch the current user data to get the current profile image URL
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let currentImageUrlString = document.data()?["profileImageUrl"] as? String {
                    // Delete the previous image from Firebase Storage
                    let storage = Storage.storage()
                    let storageRef = storage.reference(forURL: currentImageUrlString)
                    
                    storageRef.delete { error in
                        if let error = error {
                            print("Error deleting previous image: \(error.localizedDescription)")
                        } else {
                            print("Previous image deleted successfully")
                        }
                    }
                }
            }
        }
    }

    func saveProfileImageUrlToFirestore(url: URL) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Assuming you have a Firestore collection named "users"
            let db = Firestore.firestore()// Replace with the actual user ID
            
            db.collection("users").document(userId).updateData(["profileImageUrl": url.absoluteString]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
        } catch {
            print("Failed to save with error \(error.localizedDescription)")
        }
    }


}


struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfilePage()
    }
}
