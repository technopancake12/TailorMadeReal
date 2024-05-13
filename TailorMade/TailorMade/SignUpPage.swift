//
//  SignUpPage.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/3/24.
//

import SwiftUI

struct Item: Identifiable { // defining items for table
    let id = UUID()
    let title: String
    let imageName: String
    var isSelected: Bool = false
}

struct BrandInterest: View {
    @State private var items: [Item] = [
        //Table of brands for user to select
        Item(title: "Adidas", imageName: "adidas"),
        Item(title: "Nike", imageName: "nike"),
        Item(title: "Comme Des Garcons", imageName: "commedesgarcons"),
        Item(title: "Stussy", imageName: "stussy"),
        Item(title: "ACOLDWALL", imageName: "acoldwall"),
        Item(title: "Off-White", imageName: "offwhite"),
        Item(title: "Supreme", imageName: "supreme"),
        Item(title: "ARCTERYX", imageName: "arcteryx"),
        Item(title: "Champion", imageName: "champion"),
        Item(title: "JADED LONDON", imageName: "jadedlondon"),
        Item(title: "Vans", imageName: "vans"),
        Item(title: "Doc Martens", imageName: "docmartens"),
        Item(title: "Maison Margiela", imageName: "imageX"),
        Item(title: "Rick Owens", imageName: "imageX"),
        Item(title: "ISSEY MIYAKE", imageName: "imageX"),
        Item(title: "Suicoke", imageName: "imageX"),
        Item(title: "Vivienne Westwood", imageName: "imageX"),
        Item(title: "MIHARA YASUHIRO", imageName: "imageX"),
        Item(title: "Gentle Monster", imageName: "imageX"),
        Item(title: "NOMAINTENANCE", imageName: "imageX"),
        Item(title: "New Balance", imageName: "imageX"),
        Item(title: "KAPITAL", imageName: "imageX"),
        Item(title: "Evisu", imageName: "imageX")
    ]
    @State private var navigateToSignUpPage = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(items) { item in
                        ItemRow(item: item)
                    }
                }
            }
            .navigationTitle("Which brands are you most interested in?")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Done") {
                    navigateToSignUpPage = true
                }
                .sheet(isPresented: $navigateToSignUpPage) {
                    SignUpPage()
                }
            )
        }
    }
}

struct ItemRow: View {
    @State private var selectedItems: Set<UUID> = Set()
    let item: Item
    
    var body: some View { //definition of items in table
        HStack {
            Image(item.imageName)
                .resizable()
                .frame(width: 50, height: 50)
            Text(item.title)
            Spacer()
            if selectedItems.contains(item.id) {
                Image(systemName: "checkmark.square.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "square")
            }
        }
        .onTapGesture { //track if the user selects the brand
            toggleSelection(for: item)
        }
    }
    
    func toggleSelection(for item: Item) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
}

struct BrandInterest_Previews: PreviewProvider {
    static var previews: some View {
        BrandInterest()
    }
}


// SignUpPage view
struct SignUpPage: View {
    
    @State private var fullname = ""
    @State private var Username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var profileImageUrl = "download"
    @State private var bio = ""
    @State private var navigateToBrandInterest = false  // Added new state variable
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background styling - Sharvay
                Color.blue
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white)
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                
                VStack {
                    // App title
                    Text("Tailor Made")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    // Full name text field - Sharvay
                    TextField("Full Name", text: $fullname)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    TextField("Username", text: $Username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    // Email text field - Sharvay
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)

                    // Password secure field - Sharvay
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    // Confirm password secure field with validation indicator - Sharvay
                    ZStack(alignment: .trailing){
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                            }
                        }
                    }
                    
                    
                    
                    

                    // Sign Up button - Hoang
                    Button("Sign Up") {
                        Task {
                            try await viewModel.CreateUser(withEmail: email, password: password, fullname: fullname, Username: Username, profileImageUrl: profileImageUrl, bio: bio)
                            navigateToBrandInterest = true   // Set navigateToBrandInterest to true
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .fullScreenCover(isPresented: $navigateToBrandInterest) {  // Present BrandInterest view
                        BrandInterest()
                    }
                        
                    // Navigation link to log in page - Hoang
                    NavigationLink() {
                        LoginPage()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3){
                            Text("Already have an Account?")
                            Text("Log In")
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
    }
}

// Extension for form validation - Hoang
extension SignUpPage: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !fullname.isEmpty
        && confirmPassword == password
    }
}

// Preview for the sign-up page
struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage()
    }
}
