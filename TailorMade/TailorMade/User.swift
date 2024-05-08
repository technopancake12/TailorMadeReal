//
//  User.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/3/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let Username: String
    let profileImageUrl: String
    let bio: String
    
//    init(data: [String:Any]) {
//        self.id = data["id"] as? String ?? "ID"
//        self.fullname = data["fullname"] as? String ?? "Fullname"
//        self.email = data["email"] as? String ?? "Email"
//
//    }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

//extension User {
//    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Ian Bundy Weiss", email: "ian@gmail.com")
//}
