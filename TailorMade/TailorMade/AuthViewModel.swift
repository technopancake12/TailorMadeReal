//
//  AuthViewModel.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/3/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    let db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
       }
    }
    
    func SignIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to Log In with error \(error.localizedDescription)")
        }
    }
    
    func CreateUser(withEmail email: String, password: String, fullname: String, Username: String, profileImageUrl: String, bio: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let uid = result.user.uid
            let user = User(id: result.user.uid, fullname: fullname, email: email, Username: Username, profileImageUrl: profileImageUrl, bio: bio)
            try await db.collection("users").document(user.id).setData([
                "id": uid,
                "email": email,
                "password": password,
                "fullname": fullname,
                "Username": Username,
                "bio": bio
            ])
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create User with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.userSession = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        do {
           
        }
    }

    func fetchUser() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userId)

            if let document = try? await userRef.getDocument() {
                if document.exists {
                    let userData = document.data()
                    self.currentUser = User(id: userId, fullname: userData!["fullname"] as? String ?? "", email: userData!["email"] as? String ?? "", Username: userData!["Username"] as? String ?? "", profileImageUrl: userData!["profileImageUrl"] as? String ?? "", bio: userData!["bio"] as? String ?? "")
                    print("DEBUG: Current user is \(self.currentUser)")
                } else {
                    print("User document does not exist.")
                }
            }
        } catch {
            print("Failed to fetch user with error \(error.localizedDescription)")
        }
    }
}
