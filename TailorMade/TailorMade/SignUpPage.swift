//
//  SignUpPage.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/3/24.
//

import SwiftUI

// SignUpPage view
struct SignUpPage: View {
    
    @State private var fullname = ""
    @State private var Username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var profileImageUrl = "download"
    @State private var bio = ""
    
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
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                        
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
